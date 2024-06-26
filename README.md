# scripts

A loose collection of useful scripts and functions that we use at REBEL

## Python

Python scripts can be loaded from your script as follows:


```python
import requests

# For the data_OSF.py script
exec(requests.get("https://raw.githubusercontent.com/RealityBending/scripts/main/data_OSF.py").text)
```
