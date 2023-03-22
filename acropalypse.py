import struct
import sys
import requests
from urllib.parse import urlparse

def fetch_data(input_source):
    if is_url(input_source):
        return fetch_remote_data(input_source)
    else:
        return fetch_local_data(input_source)

def is_url(input_source):
    try:
        result = urlparse(input_source)
        return result.scheme in ('http', 'https')
    except ValueError:
        return False

def fetch_local_data(filepath):
    try:
        with open(filepath, 'rb') as file:
            data = file.read()
        return data
    except FileNotFoundError:
        print(f"File not found: {filepath}")
        return None

def fetch_remote_data(url):
    response = requests.get(url)
    if response.status_code != 200:
        print(f"Failed to fetch the PNG file from the URL: {url}")
        return None
    return response.content

def main(input_source):
    data = fetch_data(input_source)
    if not data:
        return

    png_signature = b'\x89PNG\r\n\x1a\n'
    iend_chunk = b'IEND'

    if not data.startswith(png_signature):
        print(f"The file at {input_source} is not a valid PNG file.")
        return

    iend_index = data.find(iend_chunk)

    if iend_index == -1:
        print(f"The file at {input_source} is not a valid PNG file.")
        return

    iend_length = 4
    crc_length = 4
    iend_full_chunk_length = iend_length + crc_length

    if len(data) > iend_index + iend_full_chunk_length:
        print(f"The file at {input_source} has data beyond the IEND marker.")
    else:
        print(f"The file at {input_source} does not have data beyond the IEND marker.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <local_file_path_or_url_to_png_file>")
    else:
        main(sys.argv[1])