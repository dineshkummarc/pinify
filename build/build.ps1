Param($version)

#Get a version number and set paths to the js and css files
if ($version -Eq $null) {
    $version = Read-Host "Please provide a version number"
}

$FilePath = "..\tests\js\jquery.pinify.js"
$file = get-item -path $FilePath
$minFile = $file.FullName.Replace(".js", ".min.js")

$cssFilePath = "..\tests\css\jquery.pinify.css"
$cssFile = get-item -path $cssFilePath
$cssMinFile = $cssFile.FullName.Replace(".css", ".min.css")

#Update Version Number and set timestamp on .js file
$currentText = "^* jQuery pinify Plugin v.+$"
$newText = " jQuery pinify Plugin v$version"
$date = get-date -uformat "%A %b %d %Y %R:%S %Z"
$currentDateText = "^* Date: .+$"
$newDateText = " Date: $date"

(Get-Content $FilePath) | 
Foreach-Object {$_ -replace $currentText, $newText} | 
Set-Content $FilePath

(Get-Content $FilePath) | 
Foreach-Object {$_ -replace $currentDateText, $newDateText} | 
Set-Content $FilePath

#Get path information for Java and yuiCompressor
$currentPath = (get-location).Path
$libPath = "$currentPath\lib"

$javaCommand = "C:\Program Files (x86)\Java\jre6\bin\java"
$yuicompressorPath = "$libPath\yuicompressor-2.4.2.jar"

#Minify js and css
write-host "Preparing to minify JavaScript file at '$File'"
& $javaCommand -jar $yuicompressorPath -o $minFile $file.FullName

write-host "Preparing to minify CSS file at '$cssFile'"
& $javaCommand -jar $yuicompressorPath --type 'css' -o $cssMinFile $cssFile.FullName

if (get-item -path $minFile) {
    write-host "Minification complete"
} else {
    write-host "Minification failed. Please see log for errors"
}

write-host "Preparing to copy JavaScript files to release directories"

#Copy regular and minified files to dev and sample folders
$devfolderPath = $FilePath.Remove($FilePath.LastIndexOf("\")+1)
$jsPath = "..\js\"
$samplePath = "..\sample\js"

$children = get-childItem -path $devfolderPath -include *.pinify* -Recurse

foreach($item in $children) {
    copy-item $item.FullName -destination $jsPath
    copy-item $item.FullName -destination $samplePath
}

if ($children.count -Gt 1) {
    $count = $children.count
} else {
    $count = 1
}

write-host "Copied $count file(s) to $jsPath and $samplePath"

$cssDevFolderPath = $cssFilePath.Remove($FilePath.LastIndexOf("\")+1)
$cssPath = "..\css\"
$cssSamplePath = "..\sample\css"

$children = get-childItem -path $cssDevfolderPath -include *.pinify* -Recurse

foreach($item in $children) {
    copy-item $item.FullName -destination $cssPath
    copy-item $item.FullName -destination $cssSamplePath
}

if ($children.count -Gt 1) {
    $count = $children.count
} else {
    $count = 1
}

write-host "Copied $count file(s) to $cssPath and $cssSamplePath"
read-host "Press enter to close..."