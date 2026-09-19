import os
import shutil

def collect_dart_files(destination_folder="collected_dart_files"):
    current_directory = os.getcwd()
    destination_path = os.path.join(current_directory, destination_folder)

    if not os.path.exists(destination_path):
        os.makedirs(destination_path)

    for root, dirs, files in os.walk(current_directory):
        if root == destination_path:
            continue
        for file in files:
            if file.endswith(".dart"):
                source_file_path = os.path.join(root, file)
                target_file_path = os.path.join(destination_path, file)
                counter = 1
                base_name, extension = os.path.splitext(file)
                while os.path.exists(target_file_path):
                    new_file_name = f"{base_name}_{counter}{extension}"
                    target_file_path = os.path.join(destination_path, new_file_name)
                    counter += 1
                shutil.copy2(source_file_path, target_file_path)

if __name__ == "__main__":
    collect_dart_files()
