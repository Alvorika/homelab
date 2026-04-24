# JupyterHub configuration with DockerSpawner + Authelia OIDC
import os
import subprocess
import asyncio
from dockerspawner import DockerSpawner
from oauthenticator.generic import GenericOAuthenticator
import yaml
import pwd
import grp

c = get_config()

# --- Hub Network ---
c.JupyterHub.hub_ip = '0.0.0.0'
c.JupyterHub.hub_connect_ip = 'hub'
c.JupyterHub.hub_port = 8081

# --- Database ---
c.JupyterHub.db_url = 'sqlite:////data/jupyterhub.sqlite'

# --- Available Images ---
AVAILABLE_IMAGES = {
    "Default Notebook (CPU)": {
        "image_tag": "quay.io/jupyter/base-notebook:x86_64-ubuntu-22.04",
        "data_subdir": "cpu_data",
        "is_custom": False
    },
    "PyTorch Environment (GPU)": {
        "image_tag": "gpu-notebook:torch128",
        "data_subdir": "gpu_data",
        "is_custom": True
    },
    "R Environment (CPU)": {
        "image_tag": "jupyter/r-notebook:x86_64-ubuntu-22.04",
        "data_subdir": "r_data",
        "is_custom": False
    },
}

default_cpu_image_info = AVAILABLE_IMAGES["Default Notebook (CPU)"]
gpu_image_info = AVAILABLE_IMAGES["PyTorch Environment (GPU)"]
r_image_info = AVAILABLE_IMAGES["R Environment (CPU)"]

# --- Spawner ---
class DemoFormSpawner(DockerSpawner):
    def _options_form_default(self):
        options_html = ""
        default_selected_tag = default_cpu_image_info['image_tag']
        for display_name, image_details in AVAILABLE_IMAGES.items():
            image_tag = image_details['image_tag']
            selected_attr = 'selected' if image_tag == default_selected_tag else ''
            options_html += f'<option value="{image_tag}" {selected_attr}>{display_name}</option>'
        return f"""
        <label for="image_choice">Select your desired stack:</label>
        <select name="image_choice" class="form-control" size="1">
        {options_html}
        </select>
        """

    def options_from_form(self, formdata):
        options = {}
        selected_image_tag_list = formdata.get('image_choice', [default_cpu_image_info['image_tag']])
        selected_image_tag = selected_image_tag_list[0]
        self.log.info(f"SPAWN_FORM: User selected image tag: {selected_image_tag}")
        self.image = selected_image_tag
        options['image'] = selected_image_tag

        self.selected_data_subdir_for_hook = "default_data_fallback"
        for display_name, image_details in AVAILABLE_IMAGES.items():
            if image_details['image_tag'] == selected_image_tag:
                self.selected_data_subdir_for_hook = image_details['data_subdir']
                break

        if not hasattr(self, 'extra_host_config') or not isinstance(self.extra_host_config, dict):
            self.extra_host_config = {}
        self.extra_host_config['group_add'] = ['100']

        if selected_image_tag == gpu_image_info['image_tag']:
            self.log.info(f"SPAWN_FORM: Configuring GPU access")
            self.extra_host_config.update({
                'device_requests': [
                    {'driver': 'nvidia', 'count': -1, 'capabilities': [['gpu', 'nvidia', 'compute', 'utility']]}
                ]
            })
        return options

    async def pre_spawn_hook(self, spawner):
        username = spawner.user.name
        selected_image_tag = self.image
        selected_data_subdir = getattr(self, 'selected_data_subdir_for_hook', 'default_data_fallback')

        selected_image_details = None
        for details in AVAILABLE_IMAGES.values():
            if details['image_tag'] == selected_image_tag:
                selected_image_details = details
                break

        is_custom_image = selected_image_details.get('is_custom', False) if selected_image_details else False

        host_base_dir_template = "/home/{username}/jupyterhub_data"
        user_specific_base_dir = host_base_dir_template.format(username=username)
        host_work_path = os.path.join(user_specific_base_dir, selected_data_subdir)
        persistent_work_dir_in_container = "/home/jovyan/work"

        try:
            stat_info = os.stat(f"/home/{username}")
            target_uid = str(stat_info.st_uid)
            target_gid = str(stat_info.st_gid)
        except Exception as e:
            self.log.error(f"Failed to stat /home/{username}: {e}, falling back to 1000:100")
            target_uid, target_gid = "1000", "100"

        script_path = "/opt/jupyterhub_scripts/prepare_user_dir.sh"

        if is_custom_image:
            self.log.info(f"Applying CUSTOM image policy for {selected_image_tag}")
            host_kernels_path = os.path.join(user_specific_base_dir, "kernels", selected_data_subdir)
            persistent_kernels_dir_in_container = "/home/jovyan/.local/share/jupyter/kernels"
            host_uv_cache_path = os.path.join(user_specific_base_dir, "uv_cache", selected_data_subdir)
            persistent_uv_cache_dir_in_container = "/home/jovyan/.cache/uv"

            os.makedirs(host_work_path, exist_ok=True)
            os.makedirs(host_kernels_path, exist_ok=True)
            os.makedirs(host_uv_cache_path, exist_ok=True)

            await asyncio.to_thread(subprocess.run, [script_path, username, user_specific_base_dir, target_uid, target_gid], check=True)

            self.volumes = {
                host_work_path: {"bind": persistent_work_dir_in_container, "mode": "rw"},
                host_kernels_path: {"bind": persistent_kernels_dir_in_container, "mode": "rw"},
                host_uv_cache_path: {"bind": persistent_uv_cache_dir_in_container, "mode": "rw"}
            }
            self.extra_create_kwargs['user'] = f"{target_uid}:{target_gid}"
        else:
            self.log.info(f"Applying OFFICIAL image policy for {selected_image_tag}")
            os.makedirs(host_work_path, exist_ok=True)
            await asyncio.to_thread(subprocess.run, [script_path, username, user_specific_base_dir, target_uid, target_gid], check=True)
            self.volumes = {
                host_work_path: {"bind": persistent_work_dir_in_container, "mode": "rw"}
            }
            self.environment['NB_UID'] = target_uid
            self.environment['NB_GID'] = target_gid
            if 'user' in self.extra_create_kwargs:
                del self.extra_create_kwargs['user']

        self.notebook_dir = persistent_work_dir_in_container

c.JupyterHub.spawner_class = DemoFormSpawner
c.DockerSpawner.network_name = os.environ.get("DOCKER_NETWORK_NAME", "jupyterhub-network")
c.DockerSpawner.remove = True
c.DockerSpawner.debug = True
c.DockerSpawner.extra_host_config = {
    'shm_size': '48G'
}
c.DockerSpawner.cmd = ['jupyterhub-singleuser']

# --- OIDC Authentication (Authelia) ---
c.JupyterHub.authenticator_class = GenericOAuthenticator
c.GenericOAuthenticator.client_id = 'jupyterhub'
client_secret = os.environ.get('OAUTH_CLIENT_SECRET')
if not client_secret:
    raise ValueError("OAUTH_CLIENT_SECRET environment variable not set.")
c.GenericOAuthenticator.client_secret = client_secret
c.GenericOAuthenticator.oauth_callback_url = 'https://jupyter.${DOMAIN}/hub/oauth_callback'
c.GenericOAuthenticator.authorize_url = 'https://auth.${DOMAIN}/api/oidc/authorization'
c.GenericOAuthenticator.token_url = 'http://authelia:9091/api/oidc/token'
c.GenericOAuthenticator.userdata_url = 'http://authelia:9091/api/oidc/userinfo'
c.GenericOAuthenticator.username_key = 'preferred_username'
c.GenericOAuthenticator.scope = ['openid', 'profile', 'email', 'groups']

# --- Dynamic User Loading from Authelia ---
authelia_users_file = '/opt/authelia/users_database.yml'
allowed_authelia_users = set()
try:
    with open(authelia_users_file, 'r') as f:
        authelia_config = yaml.safe_load(f)
        if authelia_config and 'users' in authelia_config:
            for username, user_details in authelia_config['users'].items():
                if not (user_details and user_details.get('disabled', False)):
                    allowed_authelia_users.add(username)
            print(f"Loaded {len(allowed_authelia_users)} active users from Authelia config")
except Exception as e:
    print(f"Warning: Could not load Authelia users: {e}")

c.GenericOAuthenticator.allowed_users = allowed_authelia_users if allowed_authelia_users else set()

admin = os.environ.get("JUPYTERHUB_ADMIN")
if admin:
    c.Authenticator.admin_users = {admin}
    if admin not in c.GenericOAuthenticator.allowed_users:
        c.GenericOAuthenticator.allowed_users.add(admin)

# --- Allowed Images ---
c.DockerSpawner.allowed_images = {
    details['image_tag']: details['image_tag']
    for display_name, details in AVAILABLE_IMAGES.items()
}

c.JupyterHub.log_level = 'INFO'
