# park3000-updates

## Description

Ruby / js optimizations for Park3000

## Background

Park3000 is our team project where we built a website (on top of rails app server) to retrieve the location of parking bays data and their availability in Melbourne's CBD.

## Point compression

Encodes a list of GPS coordinates (lat, long) into compressed string (base-64)

Converting working js code (and Jest code) into rb and setting-up up rspec unit tests for development and rubocop for code quality

Original code from Microsoft Bing Maps 
- [Encoding algorithm](https://docs.microsoft.com/en-us/bingmaps/rest-services/elevations/point-compression-algorithm?redirectedfrom=MSDN)
- [Decoding algorithm](https://docs.microsoft.com/en-us/bingmaps/spatial-data-services/geodata-api)
