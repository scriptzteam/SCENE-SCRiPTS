<?php

function crc32_file($fileName)
{
    $crc = hash_file("crc32b", $fileName);
    $crc = sprintf("%08X", 0x100000000 + hexdec($crc));
    return substr($crc, 6, 2) . substr($crc, 4, 2) . substr($crc, 2, 2) . substr($crc, 0, 2);
}

echo crc32_file("http://example.com/dl/c1f35b6eff6d7d4039da371be48a1c93.nfo");

?>