package main

import (
	"compress/gzip"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gocolly/colly/v2"
	"github.com/spf13/pflag"
	"github.com/spf13/viper"
)

const (
	ipUrl           = "https://db-ip.com/db/download/ip-to-country-lite"
	cityUrl         = "https://db-ip.com/db/download/ip-to-city-lite"
	asnUrl          = "https://db-ip.com/db/download/ip-to-asn-lite"
	linkCSSSelector = "a.btn.btn-block.icon-txt.download.free_download_link"
)

type Config struct {
	Daemon         bool
	DownloadFolder string
	Interval       int
}

func getGeoDownloadLinks(url string) ([]string, error) {
	c := colly.NewCollector()
	var urls []string
	c.OnHTML(linkCSSSelector, func(e *colly.HTMLElement) {
		link := e.Attr("href")
		urls = append(urls, link)
	})
	c.OnError(func(r *colly.Response, err error) {
		fmt.Println("Request URL:", r.Request.URL, "failed with response:", r, "\nError:", err)
	})
	err := c.Visit(url)
	if err != nil {
		return nil, err
	}
	return urls, nil
}

func downloadAndExtractFile(url, outputFolder string) error {
	if _, err := os.Stat(outputFolder); os.IsNotExist(err) {
		err := os.MkdirAll(outputFolder, os.ModePerm)
		if err != nil {
			return err
		}
	}
	fileName := url[strings.LastIndex(url, "/")+1:]
	outputFilePath := filepath.Join(outputFolder, fileName)
	if _, err := os.Stat(outputFilePath); err == nil {
		fmt.Println("File already exists:", fileName)
		return nil
	}
	outputFile, err := os.Create(outputFilePath)
	if err != nil {
		return err
	}
	defer outputFile.Close()
	response, err := http.Get(url)
	if err != nil {
		return err
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("HTTP request failed with status code: %d", response.StatusCode)
	}
	_, err = io.Copy(outputFile, response.Body)
	if err != nil {
		return err
	}
	fmt.Println("Downloaded:", fileName)
	if strings.HasSuffix(fileName, ".gz") {
		err := extractGzippedFile(outputFilePath, outputFolder)
		if err != nil {
			return err
		}
	}
	return nil
}

func extractGzippedFile(filePath, outputFolder string) error {
	fileName := filepath.Base(filePath)
	destination := filepath.Join(outputFolder, fileName[:len(fileName)-3])
	file, err := os.Open(filePath)
	if err != nil {
		return err
	}
	defer file.Close()
	reader, err := gzip.NewReader(file)
	if err != nil {
		return err
	}
	defer reader.Close()
	outFile, err := os.Create(destination)
	if err != nil {
		return err
	}
	defer outFile.Close()
	_, err = io.Copy(outFile, reader)
	if err != nil {
		return err
	}
	fmt.Println("Extracted:", fileName)
	return nil
}

func parseConfig() (Config, error) {
	viper.SetEnvPrefix("GEO_SERVICE")
	viper.AutomaticEnv()
	pflag.Int("interval", 10, "Ticker interval in seconds")
	pflag.String("download-folder", "output", "Download folder path")
	pflag.Bool("daemon", false, "Run the program in daemon mode (continuous)")
	if err := viper.BindPFlags(pflag.CommandLine); err != nil {
		return Config{}, err
	}
	pflag.Parse()
	interval := viper.GetInt("interval")
	downloadFolder := viper.GetString("download-folder")
	daemon := viper.GetBool("daemon")
	return Config{
		Interval:       interval,
		DownloadFolder: downloadFolder,
		Daemon:         daemon,
	}, nil
}

func main() {
	fmt.Println("Program geo-service is starting!")
	config, err := parseConfig()
	if err != nil {
		fmt.Println("Error parsing configuration:", err)
		return
	}
	fmt.Printf("Configuration: %+v\n", config)
	if viper.GetBool("daemon") {
		ticker := time.NewTicker(time.Duration(config.Interval) * time.Second)
		defer ticker.Stop()
		for range ticker.C {
			for _, sUrl := range []string{ipUrl, cityUrl, asnUrl} {
				dUrls, err := getGeoDownloadLinks(sUrl)
				if err != nil {
					fmt.Println("Error getting download links:", err)
					continue
				}
				fmt.Println("Download URLs:")
				for _, dUrl := range dUrls {
					err := downloadAndExtractFile(dUrl, config.DownloadFolder)
					if err != nil {
						fmt.Println("Error downloading or extracting file:", err)
					}
				}
			}
		}
	} else {
		for _, sUrl := range []string{ipUrl, cityUrl, asnUrl} {
			dUrls, err := getGeoDownloadLinks(sUrl)
			if err != nil {
				fmt.Println("Error getting download links:", err)
				return
			}
			fmt.Println("Download URLs:")
			for _, dUrl := range dUrls {
				err := downloadAndExtractFile(dUrl, config.DownloadFolder)
				if err != nil {
					fmt.Println("Error downloading or extracting file:", err)
				}
			}
		}
	}
}
