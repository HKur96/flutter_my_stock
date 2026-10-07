[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$items = @(
    @{
        name = "01_login"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1VARqETsGIagaEdpAMMqJk6aFLtvDGVDvAYW96BEuHXww4UYYnElmmC2i2rLPeoCycymqWcZWx9kSahNHvGAd4dCMjjLJH2cvDLgH3GLeCRcNY7Vy8bA3XsYTJeF-JG0m6sMSPM-nmtDKvlKxQ2Yq5oMZQMBSj0WdAlhZlb-WtRwr6UD_WQu3Ln5R3WXC0yvEbR7rfUFo7rYYN4jYZEhGcQYSvOOIjx7BHYpgSiuBQ"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMmZkM2Y2NzRhYTAyMDdhMjJkZTEzOTRjNmESCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "02_register"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1VuO_ZljocxoFp3Gfe10IAkvmuOZzNZlRH94OG_YDEMHT6xd6LBTmhQyco0OxRNH3Sg7iE8YeckbCOuMDbzmQa8UJaYWGWSqkoce6N1xgIDRvhwR7nYk8dpV1M9ZBtHVRkh2U9dPjgkCXCNdlQ9XQadTi7oA9ndAdrFvT0m3i2rP8xK27ZuNQFNZzKgLWUviIAuHFGXkoY9kHehMNgC03E5uQ7Mc4C7CMBh0y_ZGzkJ"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMmZkNDhlMGZmOTA2ZjFjMzUwY2YyOTFjYTASCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "03_dashboard"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1Vk7EZMbvAESXNmqauYQNNrZkrt0GoUrvhhTRIUj1udKR2DgSTzZv698KDImOMqOtnFmhut_cBq6EBHUNfnZzeNhtyGeo0eIOWIqMD3iL_nHYOGHutZ3R19d6x58XhYz3oDR-tFZIjzJ98v5tfHxWKWUg2sE4jwUdpRBmOLXNLX4mq72gjV6wzKtD22JgTUV7sbA0q6-OFpTmFu1bcoUT__qtkIObBLdFVvzJEwIbyDUO7aKSqJjIsCKjk"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMmZkYjI2NDUyNDA3YzRlMGU3YzEyYWRjOWMSCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "04_product_list"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1VE7qYNNW739aALh53kWRYpfpkA8b31F18Ay5HHUuiocOdjMfX92fuaguVwqJH92UsLY5NCq0wuGddpXknWhwd0Y7xYiuekoSIZuVZFbyGZrKsj-FeHNs7w0q36UhlsQxkuZTR_g-NA7nZ5645FdPuqQ8YS2no07iiiqqaQfuPX07Ms0W13xeZbWVFRn8fY9pHgAGInYGE15Z11CMxTp7ricZLr58piWFLCtdYw-DqdgQdbPzMgQD2n9A"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMmZkZjhhZjI0ODA3YzRlZTExMDAwNjNlOWESCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "05_detail_product"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1VwI2UHv79Z9MC3B1Kr0Ko3-OWNM1hhGEk1XgvIcukdayrqetSEGRn6kHM8-8Fi8b5L_EwoL6QeAeDJQUUQS0w1hEtu0Kk5tvOSoNnimbD7-3Zpp4ZYPURm46bMWpTzlcAIfSbpw7dRFWc3oQpuqv7dHKkgyKuIRvEj13Wpon-9PVfcgSRVCJ_LCUwO9R7KWvETJxabwTWqP6Ds4OrCT6DESLVxNQ5_m1hrXrZHWnml"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMzAxZDFmYzZiODA3ZTg0NTIyNGIwYTcyMDASCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "06_add_edit_product"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1VvGBNRCApVsT4KcrQoaoc93rbGdgltopmlAywf4F9zTfPcZjQ-9FqVkLC2zMyb9pzE3DyNLVmtNmUr-059NcnApYIHEbB_YNWgrTFIhuGPxGqmMFGSiOjJSQnoN9aIJeTLhjzquSGaJI0unNUSzB59Uuoc-Tcl6nfW_Hk0aGpTlQBhXv36FAzaGXmsSdLhNMclgAEFnmW2jGRmVxL3HFFdh8CO4UUEZ30CeHOUTL9o"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMzAxOGFiYjc5NzAzOTJjYjNlYjUxMTMwZWESCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "07_stock_in"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1WmX2DnZsZzSMTeOSeAn_ZWT-am1hXI7TsxQjlE6VEn6sGMoeWDlg6GqzrhXOmSyrBWU50_odwZgUA99nQ4DMlMX_vTC3nryggcl4peL-cdarxpL7vyBIK0j12TZY68UIKAhLDf8lXACBnPiLp6wU_eY4QXO9JB0oKK7HEDwj-bj98PeKZhizabLfrrRG42q7OQYRowxyU74sIMsrydPQvaxi9fdcUF5n8blykWMP6p"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMzAxNjYyZGFhMDAyMmQ0ZDY0NDcwNDc0MDcSCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "08_stock_out"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1X4JcjxEj76lFa-48IqZ_IQjdqhaYaQkenkLVRGf_R0m3lT_NDTk2555AH9dO2qBoOtufJdpUZs4h-qpQkWceGICbYRilwRZT-mei5I7jmvs2up1J7_0XzAgvHjqa4glSe3-Fw88OItY43ZIi5M4mLndIHbGjKie1AHqwcbHZq1G2MfqjOlveW9Q8WuOQpKN1QF01LxslXlmQHoWWnEVkDy7q6GFKAxkn7O2iJycQJU"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMzAxNTA2ODE3MDA4OWFmNjlkMDgyNTNkY2QSCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "09_history"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1UysTkI_kAvkQ93TbeP3hwyAkK9bhspyNFkCgPzyRe2SAANb0u4qZsFxzreCDU_yMvjcd0CDIZfGCxUyf58sSuWylXRZSYFMDp_-fRTNI5kFOiCFxL74HbrfjwXI0p-QoqydH7wT2XxELgwZIklPSlgO_fLqGFbU3UYmevOBdfQLn8VKmiRvFfg5hqNx8o7NoY8GFs3bbjqYd1NiUR4sHLrRgxZj595dX2OgODEFRU"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMzAwZjIzYTkzZDA3Nzk5MzU4NWMxNzdkMjISCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "10_manage_category"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1WEdxTA-wHQYRrZ7paESiUiblVEIMwXwDZCZHTNbqRz3qWAMHblzr9P_BgKlkUtutYB2KV3IpWkTYHRiBqRR3RG8FmiJJ1R47OQ1QsGzJvMD63d_HJfSHqiN-6mJqLQmm2PJzBiM_Ey66mklCuO_2LzdoAYg8z0bW6h3PwA02rG1Zk-I5biFiQLO67AQq6H1ts2fCzpJzxC1Lq8PEOkccwvGDHbwijmRyGqaI4UCC-0"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMzAwYWMyYTIxNjAzODNhNjQ2MmUyMThiZWQSCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    },
    @{
        name = "11_profile"
        img = "https://lh3.googleusercontent.com/aida/AEtjO1UNfsx593xyhDmAwzIWgHkYcgJ2_jyUI4his1zue58ztBRzUgMGdkCTutALG9bS633PyqX_fVAe1VrklervbJvFIhHeUvEp_UkdWKMywvMLg9n5newu42ZfNu0B2-VsKwth8pFO2USwyD_tjFwvpwrmsLYhNuDcIIENe_5vke5t3-K6NAPi2vJ7AIIF8Kr7QoI72E-IZ2yyMSIODKUvW8WChdNaPuUBGpl1KGYBqxUe6qCvVvBG7CyCaE4"
        html = "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJxEgxzdGl0Y2hfZmlsZXMaYQosc3RpdGNoX2h0bWxfMDAwNjVkMmZmZGVmMzI0ZTA3YzRjOTMxY2UzYjk2YjASCxIHEL_87eHWCxgBkgEjCgpwcm9qZWN0X2lkEhVCEzkwNDU4OTQxMjI4NTE3NzI2Nzc&filename=&opi=89354086"
    }
)

$outDir = Join-Path $PSScriptRoot "stitch_assets"
if (!(Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

foreach ($item in $items) {
    $imgFile = Join-Path $outDir "$($item.name).png"
    $htmlFile = Join-Path $outDir "$($item.name).html"

    Write-Host "Downloading $($item.name) screenshot..."
    curl.exe -L -s -o $imgFile $item.img

    Write-Host "Downloading $($item.name) html..."
    curl.exe -L -s -o $htmlFile $item.html
}

Write-Host "All assets downloaded successfully!"
