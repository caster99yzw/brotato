import subprocess
from datetime import datetime
import os
import sys

GODOT_PATH = r"D:\Godot_v4.6.2-stable_win64\Godot_v4.6.2-stable_win64.exe"
PROJECT_PATH = r"D:\brotato"
LOG_DIR = os.path.join(PROJECT_PATH, "log")

def main():
    os.makedirs(LOG_DIR, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    log_file = os.path.join(LOG_DIR, f"editor_{timestamp}.log")
    
    proc = subprocess.Popen(
        [GODOT_PATH, "-e", "--path", PROJECT_PATH, "-v"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
        universal_newlines=True
    )
    
    has_error = False
    output_lines = []
    
    while True:
        line = proc.stdout.readline()
        if not line and proc.poll() is not None:
            break
        if line:
            output_lines.append(line)
            print(line, end="")
            
            if any(x in line for x in ["SCRIPT ERROR", "Parse Error", "ERROR:"]):
                has_error = True
    
    if has_error:
        print("\nError detected, closing in 3 seconds...")
        import time
        time.sleep(3)
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
    
    with open(log_file, "w", encoding="utf-8") as f:
        f.writelines(output_lines)
    
    print(f"\nLog saved to: {log_file}")
    return proc.returncode

if __name__ == "__main__":
    sys.exit(main())
