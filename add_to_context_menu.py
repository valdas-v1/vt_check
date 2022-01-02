import winreg as _winreg
import os
import sys

# Source: http://sbirch.net/tidbits/context_menu.html
def define_action_on(filetype, registry_title, command, title=None):
    """
    define_action_on(filetype, registry_title, command, title=None)
        filetype: either an extension type (ex. ".txt") or one of the special values ("*" or "Directory"). Note that "*" is files only--if you'd like everything to have your action, it must be defined under "*" and "Directory"
        registry_title: the title of the subkey, not important, but probably ought to be relevant. If title=None, this is the text that will show up in the context menu.
    """
    # all these opens/creates might not be the most efficient way to do it, but it was the best I could do safely, without assuming any keys were defined.
    reg = _winreg.OpenKey(
        _winreg.HKEY_CURRENT_USER, "Software\\Classes", 0, _winreg.KEY_SET_VALUE
    )
    k1 = _winreg.CreateKey(
        reg, filetype
    )  # handily, this won't delete a key if it's already there.
    k2 = _winreg.CreateKey(k1, "shell")
    k3 = _winreg.CreateKey(k2, registry_title)
    k4 = _winreg.CreateKey(k3, "command")
    if title != None:
        _winreg.SetValueEx(k3, None, 0, _winreg.REG_SZ, title)
    _winreg.SetValueEx(k4, None, 0, _winreg.REG_SZ, command)
    _winreg.CloseKey(k3)
    _winreg.CloseKey(k2)
    _winreg.CloseKey(k1)
    _winreg.CloseKey(reg)


# Get current working directory
cwd = os.getcwd()

# Set path to script
app_path = os.path.join(cwd, "app.py")

key_path = r"HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\VTScan"

# Set path to python.exe
python_exe = sys.executable

define_action_on(
    "*", "Check reputation on VirusTotal", f'{python_exe} {app_path} -f "%1"'
)