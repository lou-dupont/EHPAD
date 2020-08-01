import json
from params import *
import requests


url_api = 'https://www.data.gouv.fr/api/1/datasets/'

url_etablissements = url_api + '5ca48257634f414eb3f14803'
url_points_infos = url_api + '5ca4bd618b4c414705077c3c'
url_soins_domicile = url_api + '5ca4b58c8b4c412fd295f7b1'

resource_etab_csv = 'a9218b2b-2e7e-4510-9f3f-8a4540890ec2'
resource_etab_xls = '7197d642-dab6-41a0-adc5-b599298704ed'

resource_pi_csv = '5261b353-f751-490d-83a0-10cf1c2a0ea7'
resource_pi_xls = '951a1464-9d42-4663-9cec-3d50b55d5ab1'

resource_sad_csv = '482560c9-2a97-4110-aba7-24ea99ad1f34'
resource_sad_xls = '35c82d39-70d6-4aaa-a72e-5c98905ec2ab'


def upload_file(local_name, dataset_url, resource_id):
    print('Uploading file ' + local_name)
    headers = {
        'X-API-KEY': X_API_KEY
    }
    response = requests.post(dataset_url + '/resources/' + resource_id + '/upload/', files={'file': open(local_name, 'rb')}, headers=headers)
    print('Uploaded file')
    print('Uploading metadata')
    headers = {
        'Content-Type': 'application/json',
        'X-API-KEY': X_API_KEY
    }
    old_data = response.json()
    data = { 
        'published': old_data['last_modified']
    }
    response = requests.put(dataset_url + '/resources/' + resource_id + '/', data=json.dumps(data), headers=headers)
    print('Uploaded metadata')

upload_file('base_etablissements.csv', url_etablissements, resource_etab_csv)
upload_file('base_etablissements.xlsx', url_etablissements, resource_etab_xls)
upload_file('base_points_info.csv', url_points_infos, resource_pi_csv)
upload_file('base_points_info.xlsx', url_points_infos, resource_pi_xls)
upload_file('base_soins_a_domicile.csv', url_soins_domicile, resource_sad_csv)
upload_file('base_soins_a_domicile.xlsx', url_soins_domicile, resource_sad_xls)
