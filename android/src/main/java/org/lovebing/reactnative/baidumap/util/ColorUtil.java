/**
 * Copyright (c) 2016-present, lovebing.org.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package org.lovebing.reactnative.baidumap.util;

import android.graphics.Color;

import java.math.BigInteger;

/**
 * @author lovebing Created on Dec 09, 2018
 */
public class ColorUtil {

    public static int fromString(String color) {
        if (color.startsWith("0x")) {
            color = "#" + color.substring(2);
        } else if (!color.startsWith("#")) {
            color = "#" + color;
        }
        if (color.length() == 9) {
            color = "#" + color.substring(7, 9) + color.substring(1, 7);
        }

        return Color.parseColor(color);
    }
}
