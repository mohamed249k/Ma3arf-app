path = r'android/app/src/main/AndroidManifest.xml'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

target = 'android:icon="@mipmap/ic_launcher"'
replacement = 'android:icon="@mipmap/ic_launcher"\n        android:roundIcon="@mipmap/ic_launcher_round"'

if target in text:
    text = text.replace(target, replacement, 1)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print('Updated AndroidManifest.xml successfully!')
else:
    print('Target not found in AndroidManifest.xml')
