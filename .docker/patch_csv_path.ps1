$origen = 'C:/xampp/mysql/Taller_Municipios/municipios.csv'
$destino = '/csv-data/municipios.csv'
$c = Get-Content -Raw -Encoding UTF8 'Cargue de datos.sql'
$c = $c.Replace($origen, $destino)
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText('.docker\Cargue_docker.sql', $c, $utf8)
