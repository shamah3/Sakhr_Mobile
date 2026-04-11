Add-Type -AssemblyName System.Drawing
$path = 'c:\Users\DELL\IdeaProjects\ecom_mobail-main\assets\icons\sakhr_logo.png'
$dest = 'c:\Users\DELL\IdeaProjects\ecom_mobail-main\assets\icons\sakhr_logo_square.png'
$img = [System.Drawing.Image]::FromFile($path)
$size = [math]::Max($img.Width, $img.Height)
$w = [int]($size * 1.7)
$bmp = New-Object System.Drawing.Bitmap $w, $w
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::White)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$x = [int](($w - $img.Width) / 2)
$y = [int](($w - $img.Height) / 2)
$g.DrawImage($img, $x, $y, $img.Width, $img.Height)
$bmp.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
$img.Dispose()
Write-Host "Done"
