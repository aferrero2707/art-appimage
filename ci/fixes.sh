make_temp_libdir() {
	AILIBDIR="$(mktemp -d -t ailibdir.XXXX)"
	export AILIBDIR
}


link_libraries() {
	ln -s "$APPDIR/usr/lib"/*.so* "$AILIBDIR"
}


fix_libxcb_dri3() {
	libxcbdri3="$(/sbin/ldconfig -p | grep 'libxcb-dri3.so.0 (libc6,x86-64'| awk 'NR==1{print $NF}')"
	temp="$(strings $libxcbdri3 | grep xcb_dri3_get_supported_modifiers)"
	if [ -n "$temp" ]; then
		echo "deleting $AILIBDIR/libxcb-dri3.so*"
		rm -f "$AILIBDIR"/libxcb-dri3.so*
	fi
}


fix_stdlibcxx() {
# libstdc++ version detection
stdcxxlib="$(/sbin/ldconfig -p | grep 'libstdc++.so.6 (libc6,x86-64)'| awk 'NR==1{print $NF}')"
echo "System stdc++ library: \"$stdcxxlib\""
stdcxxver1=$(strings "$stdcxxlib" | grep '^GLIBCXX_[0-9].[0-9]*' | cut -d"_" -f 2 | sort -V | tail -n 1)
echo "System stdc++ library version: \"$stdcxxver1\""
stdcxxver2=$(strings "$APPDIR/usr/optional/libstdc++/libstdc++.so.6" | grep '^GLIBCXX_[0-9].[0-9]*' | cut -d"_" -f 2 | sort -V | tail -n 1)
echo "Bundled stdc++ library version: \"$stdcxxver2\""
stdcxxnewest=$(echo "$stdcxxver1 $stdcxxver2" | tr " " "\n" | sort -V | tail -n 1)
echo "Newest stdc++ library version: \"$stdcxxnewest\""
	if [[ x"$stdcxxnewest" = x"$stdcxxver1" ]]; then
   		echo "Using system stdc++ library"
	else
   		echo "Using bundled stdc++ library"
		ln -s "$APPDIR/usr/optional/libstdc++"/*.so* "$AILIBDIR"
	fi
}


fix_fontconfig() {
# fonconfig version detection
fclib="$(/sbin/ldconfig -p | grep 'libfontconfig' | grep '(libc6,x86-64)'| awk 'NR==1{print $NF}')"
if [ -n "$fclib" ]; then
        fclib=$(readlink -f "$fclib")
        fcv=$(basename "$fclib" | tail -c +18)
fi
fclib2="$(ls $APPDIR/usr/optional/fontconfig/libfontconfig.so.*.*.* | head -n 1)"
if [ -n "$fclib2" ]; then
        fclib2=$(readlink -f "$fclib2")
        fcv2=$(basename "$fclib2" | tail -c +18)
fi
echo "fcv: \"$fcv\"  fcv2: \"$fcv2\""
if [ x"$fclib" = "x" ]; then
   echo "Ssystem fontconfig missing, using bundled fontconfig library"
   ln -s "$APPDIR/usr/optional/fontconfig"/*.so* "$AILIBDIR"
   export FONTCONFIG_PATH="$APPDIR/usr/etc/fonts/fonts.conf"
fi
if [ x"$fclib" != "x" -a x"$fclib2" != "x" ]; then
   echo "echo \"$fcv $fcv2\" | tr \" \" \"\n\" | sort -V | tail -n 1"
   fcvnewest=$(echo "$fcv $fcv2" | tr " " "\n" | sort -V | tail -n 1)

   echo "Newest fontconfig library version: \"$fcvnewest\""
   if [[ x"$fcvnewest" = x"$fcv" ]]; then
      echo "Using system fontconfig library"
   else
      echo "Using bundled fontconfig library"
      ln -s "$APPDIR/usr/optional/fontconfig"/*.so* "$AILIBDIR"
      export FONTCONFIG_PATH="$APPDIR/usr/etc/fonts/fonts.conf"
   fi
fi
}
