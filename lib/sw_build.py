import subprocess
import os
import shutil

class SwBuildHelper:

    def __init__(self, export_folder_path):
        self.export_folder_path = export_folder_path

    def package_export_file(self):
        # make export path
        if not os.path.exists(self.export_folder_path):
            os.makedirs(self.export_folder_path)

        # create data folder
        data_folder = os.path.join(self.export_folder_path, "data")
        if not os.path.exists(data_folder):
            os.makedirs(data_folder)

        # base paths
        lib_dir      = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.abspath(os.path.join(lib_dir, ".."))
        # source paths
        sw_dir     = os.path.join(project_root, "sw")
        driver_src = os.path.join(sw_dir, "driver")
        test_src   = os.path.join(sw_dir, "myTest.ipynb")

        # destination paths
        driver_dst = os.path.join(self.export_folder_path, "driver")
        test_dst   = os.path.join(self.export_folder_path, "test.ipynb")

        # Copy driver folder
        if os.path.exists(driver_src):
            if os.path.exists(driver_dst):
                shutil.rmtree(driver_dst)
            shutil.copytree(driver_src, driver_dst)

        # Copy myTest.ipynb as test.ipynb
        shutil.copy(test_src, test_dst)
        
        

        