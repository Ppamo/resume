# Resume

New design for my own resume.   The design was 'inspired' by a Latex Template that can be found [here](https://www.latextemplates.com/template/developer-cv).

It can be built from the .svg files, by executing command:
```bash
bash builder/builder.sh
```

This script will initiate a container, that join the .svg pages into a single .pdf file by executing the convert.sh script which uses **inkskape** to export the .svg files into pdf files and then uses **ghostscript** to join the pages.

