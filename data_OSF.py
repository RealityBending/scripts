# Get files from OSF ======================================================
def osf_listfiles(data_subproject="", token="", after_date=None):
    """Function to connect and access files from an OSF project."""

    # Load libraries
    try:
        import pandas as pd
    except ImportError:
        raise ImportError("Please install 'pandas' (`pip install pandas`)")
    try:
        import osfclient
    except ImportError:
        raise ImportError("Please install 'osfclient' (`pip install osfclient`)")

    # Connect to project
    osf = osfclient.OSF(token=token).project(data_subproject)  # Connect to project
    storage = [s for s in osf.storages][0]  # Access storage component
    files = [
        {
            "name": file.name.replace(".csv", ""),
            "date": pd.to_datetime(file.date_created),
            "url": file._download_url,
            "size": file.size,
            "file": file,
        }
        for file in storage.files
    ]

    # Filter files by date
    if after_date is not None:
        date = pd.to_datetime(after_date, format="%d/%m/%Y", utc=True)
        files = [f for f, d in zip(files, [f["date"] > date for f in files]) if d]

    return files


def osf_download(file):
    """Safe download of files from OSF."""

    try:
        import pandas as pd
    except ImportError:
        raise ImportError("Please install 'pandas' (`pip install pandas`)")
    import json

    download_ok = False
    while download_ok == False:
        if ".json" in file["name"]:
            data = json.load(file["file"]._get(file["url"], stream=True).raw)
        else:
            data = pd.read_csv(file["file"]._get(file["url"], stream=True).raw)

        if len(data) > 0:
            download_ok = True

    return data
