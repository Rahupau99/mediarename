# mediarename — Stata Audio & Image Backcheck Automation

**Author:** Rahul Paul  (J-PAL South Asia)
**Version:** 1.0.0  
**Stata Version Required:** 15+

---

## Overview

This package provides two commands to automate the renaming and syncing of raw SurveyCTO media files (audio and images) to a destination folder (e.g., Google Drive) based on a respondent ID.

---

## Commands

| Command | Description |
|---|---|
| `audiorename` | Renames & copies `.m4a` audio files by respondent ID |
| `imagerename` | Renames & copies `.jpg` image files by respondent ID |

---

## Installation

### Via GitHub (recommended)
```stata
net install mediarename, from("https://raw.githubusercontent.com/Rahupau99/mediarename/main/ado/")
