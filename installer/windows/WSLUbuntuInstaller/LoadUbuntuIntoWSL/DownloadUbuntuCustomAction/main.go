package main

import "io"
import "fmt"
import "net/http"
import "os"
import "archive/zip"
import "path/filepath"
import "strings"
import "os/exec"

func main() {
    
	baseDir := os.TempDir()
	appxUrl := "https://aka.ms/wsl-ubuntu-1804"
	zipPath := filepath.Join(baseDir, "Ubuntu1804.appx.zip")
    destPath := filepath.Join(baseDir, "Ubuntu")
	execPath := filepath.Join(destPath, "ubuntu1804.exe")

	fmt.Printf("Downloading Ubuntu install package from %s\n", appxUrl)

	// Download Ubuntu 18.04 .appx package from MS Store 
	// (this is actually a plain zip file so we rename it straight away)
	err := FileDownload(zipPath, appxUrl)
    
	if err != nil {
        panic(err)
    }
	
	fmt.Printf("Extracting downloaded package to %s\n", destPath)

	// Unzip the downloaded .appx package
	_, unzipErr := FileUnzip(zipPath, destPath)
	
	if unzipErr != nil {
        panic(unzipErr)
    }

	fmt.Printf("Initializing Ubuntu with default options\n")
	fmt.Printf("(may take a few minutes)\n")

	// Launch Ubuntu installer with default initialization options
    cmd := exec.Command(execPath, "install", "--root")

	_, execErr := cmd.CombinedOutput()

    if execErr != nil {
        panic(execErr)
    }

	fmt.Printf("Ubuntu installed successfully\n")
}

func FileDownload(localFile string, remoteUrl string) error {

    resp, err := http.Get(remoteUrl)
    
	if err != nil {
        return err
    }
    
	defer resp.Body.Close()

    out, err := os.Create(localFile)
    
	if err != nil {
        return err
    }
    
	defer out.Close()

    _, err = io.Copy(out, resp.Body)
    return err
}

func FileUnzip(sourceFile string, destDir string) ([]string, error) {
	
	var filenames []string

    input, err := zip.OpenReader(sourceFile)
    
	if err != nil {
        return filenames, err
    }
    
	defer input.Close()

    for _, f := range input.File {

        fp := filepath.Join(destDir, f.Name)

        if !strings.HasPrefix(fp, filepath.Clean(destDir) + string(os.PathSeparator)) {
            return filenames, fmt.Errorf("%s: invalid file path", fp)
        }

        filenames = append(filenames, fp)

        if f.FileInfo().IsDir() {
            // Make Directory
            os.MkdirAll(fp, os.ModePerm)
            continue
        }

        // Create File
        if err = os.MkdirAll(filepath.Dir(fp), os.ModePerm); err != nil {
            return filenames, err
        }

        outFile, err := os.OpenFile(fp, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode())
        if err != nil {
            return filenames, err
        }

        rc, err := f.Open()
        if err != nil {
            return filenames, err
        }

        _, err = io.Copy(outFile, rc)

        outFile.Close()
        rc.Close()

        if err != nil {
            return filenames, err
        }
    }
    return filenames, nil
}

