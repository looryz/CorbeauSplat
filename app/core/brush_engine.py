import os
import subprocess
import signal
import sys
import shlex
from app.core.system import resolve_binary

class BrushEngine:
    """Moteur d'execution pour Brush"""
    
    def __init__(self):
        self.brush_bin = resolve_binary("brush")
        self.process = None
        
    def train(self, input_path, output_path, iterations=30000, sh_degree=3, device="auto", with_viewer=False, custom_args=None):
        """
        Lance l'entrainement Brush.
        """
        if not self.brush_bin:
            raise RuntimeError("Exécutable 'brush' non trouvé.")
            
        # Brush n'a pas de sous-commande 'train', c'est directement l'executable
        cmd = [self.brush_bin]
        
        # Options
        # --export-path pour le dossier de sortie
        cmd.extend(["--export-path", output_path])
        
        if iterations:
            cmd.extend(["--total-steps", str(iterations)])
            
        if sh_degree:
             cmd.extend(["--sh-degree", str(sh_degree)])


        if with_viewer:
            cmd.append("--with-viewer")
            
        if custom_args:
            cmd.extend(shlex.split(custom_args))
            
        # Argument positionnel : chemin source
        cmd.append(input_path)
            
        # Environnement
        env = os.environ.copy()
        
        # Gestions du device via WGPU
        # "mps" -> metal, "cuda" -> vulkan/custom (sur Mac c'est metal)
        # On force le backend pour etre sur.
        if device == "mps":
            env["WGPU_BACKEND"] = "metal"
            env["WGPU_POWER_PREF"] = "high_performance"
            print("Force WGPU_BACKEND=metal")
        elif device == "cuda":
            env["WGPU_BACKEND"] = "vulkan" # Souvent le mapping pour cuda cross-platform ou dx12
            env["WGPU_POWER_PREF"] = "high_performance"
        elif device == "cpu":
            # Pas de variable specifique standard simple pour force CPU sur wgpu-hal sans dependance
            # Mais on peut ne pas mettre de hint
            pass
        
        # Lancement
        print(f"Lancement Brush: {' '.join(cmd)}")
        
        # Sur Windows, creationflags=subprocess.CREATE_NEW_PROCESS_GROUP
        # Sur Unix, preexec_fn=os.setsid pour pouvoir tuer le groupe de processus
        kwargs = {}
        if sys.platform != "win32":
            kwargs['preexec_fn'] = os.setsid
            
        self.process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
            env=env,
            **kwargs
        )
        
        return self.process

    def stop(self):
        """Arrête le processus en cours"""
        if self.process and self.process.poll() is None:
            if sys.platform != "win32":
                os.killpg(os.getpgid(self.process.pid), signal.SIGTERM)
            else:
                self.process.terminate()
            self.process.wait()
