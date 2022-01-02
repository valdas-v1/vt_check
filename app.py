# Python libraries
import hashlib
import webbrowser
import argparse


def VT_Scan(file_location):
    """This function will take a file location and scan it with VirusTotal.

    Args:
        file_location (str): The file location to scan.
    """

    # Generate sha256 hash of file_location
    file_hash = hashlib.sha256(open(file_location, "rb").read()).hexdigest()

    # Construct VirusTotal URL
    vt_url = "https://www.virustotal.com/gui/file/" + file_hash

    # Open VirusTotal URL in default browser
    webbrowser.open(vt_url)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="VirusTotal Scanner")
    parser.add_argument(
        "-f", "--file", help="Path to file to be scanned on VirusTotal", required=True
    )
    args = parser.parse_args()
    VT_Scan(args.file)
