# fitsservlet-docker
Custom container build for the [Harvard fits](https://github.com/harvard-lts/fits) and [Harvard fitsservlet](https://github.com/harvard-lts/FITSservlet) projects

This build is based on Harvard's latest Dockerfile with a couple of minor changes:

- A multi-stage build is used to build the file utility and download the fits and fitsservlet release artifacts
- As noted on the [Harvard FITS page](https://github.com/harvard-lts/fits?tab=readme-ov-file#media-info), the built-in mediainfo libraries are compiled for AMD64
  This build deletes those libraries and installs the system libraries, although they are a slightly older version.

Base image is tomcat:9.0.102-jre17-temurin-jammy which in turn uses eclipse-temurin:17-jre-jammy image: Ubuntu Jammy(22.04.5 LTS) with openjdk 17.0.14

