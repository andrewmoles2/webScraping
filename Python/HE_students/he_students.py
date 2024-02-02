import requests
import json
import pandas as pd

url = "https://docs.google.com/spreadsheets/d/1_DtEFPMI_URNCuRVPOJdLC2RX77ItVgqrDlGp1HzhU4/gviz/tq"

querystring = {"gid":"0","range":"A1:J4000","tqx":"reqId:1"}

payload = ""
headers = {
    "cookie": "COMPASS=apps-spreadsheets%3DCmUACWuJV6P11nLvLWOYU8C0WrqNNkn-mehxeI2vxMdi5Mi3DvDZJTBZB9ljJRh96h25dmAN12-QjnyeVrjsEC_FfU2_ApxbzBgCPcJHeICgjyeddL3wOjPZrbT8xvkVRiSdbwMHYRDejeWtBhp2AAlriVetlAnh_Xtc510ifgD7YLN7wSTQICPbGpcm0W_XnBRAzhcGruoyqPgwnO1q2kVhMvhk74ZatJ9AJG-t8xDzUUVDqfIrxHncYg8ByPpu2U3KXBZKvT8FGBJNNoWuRW-PAFq9E0vao4AU3xvrp8y3M3pSEQ%3D%3D; NID=511%3DP_laJ2l9jVnsxKDJAFxGtH_gvTxENGHvWnYGzD3yQYf9tumkYE2JbAhmSs6p4ua6bPJD9uOT-aCqx7p1D5AMzPxWiR8OXUX5FDrb7Ilk6JQ_YdmVqNu1gKoDRmh6umbcQ5nFwzDv5I_Oc3oI9wTyZB7GnPQokbTVRtvuZDhhXB4",
    "authority": "docs.google.com",
    "accept": "*/*",
    "accept-language": "en-GB,en;q=0.9",
    "origin": "https://www.hesa.ac.uk",
    "referer": "https://www.hesa.ac.uk/",
    "sec-ch-ua": "'Not_A Brand';v='8', 'Chromium';v='120', 'Brave';v='120'",
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": "'macOS'",
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "cross-site",
    "sec-gpc": "1",
    "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

response = requests.request("GET", url, data=payload, headers=headers, params=querystring)

print(response.text[:2000])
#print(response.status_code)

json_str = response.text[response.text.find('{'):response.text.rfind('}')+1]

data = json.loads(json_str)

rows = [item['c'] for item in data['table']['rows']]
headers = [col['label'] for col in data['table']['cols']]

df = pd.DataFrame(rows)

df_v = df.apply(lambda col: col.map(lambda cell: cell['v']))

df_v.columns = headers

print(df_v.head())

df_v.to_csv("Python/HE_students/HE_Domicile.csv", index=False)

