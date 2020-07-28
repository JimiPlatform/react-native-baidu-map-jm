/**
 * Copyright (c) 2016-present, lovebing.org.
 * <p>
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package org.lovebing.reactnative.baidumap.view;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.drawable.Animatable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import com.baidu.mapapi.common.SysOSUtil;
import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.Marker;
import com.baidu.mapapi.map.MarkerOptions;
import com.baidu.mapapi.model.LatLng;
import com.facebook.common.references.CloseableReference;
import com.facebook.datasource.DataSource;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.controller.ControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.DraweeHolder;
import com.facebook.imagepipeline.core.ImagePipeline;
import com.facebook.imagepipeline.image.CloseableImage;
import com.facebook.imagepipeline.image.CloseableStaticBitmap;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.views.view.ReactViewGroup;

import org.lovebing.reactnative.baidumap.R;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import static org.lovebing.reactnative.baidumap.view.OverlayInfoWindow.zoomImg;

public class OverlayMarker extends ReactViewGroup implements OverlayView {

    private Context mContext;
    private String title;
    private LatLng position = new LatLng(0, 0);
    private Float rotate;
    private Boolean flat;
    private Boolean visible;
    private Boolean perspective;
    private BitmapDescriptor iconBitmapDescriptor;
    private Marker marker;
    private DataSource<CloseableReference<CloseableImage>> dataSource;
    private DraweeHolder<?> imageHolder;
    private int mTag = -2;
    private BaiduMap mBaiduMap;
    private Thread updateThread = null;

    private final ControllerListener<ImageInfo> imageControllerListener =
            new BaseControllerListener<ImageInfo>() {
                @Override
                public void onFinalImageSet(
                        String id,
                        @Nullable final ImageInfo imageInfo,
                        @Nullable Animatable animatable) {
                    CloseableReference<CloseableImage> imageReference = null;
                    try {
                        imageReference = dataSource.getResult();
                        if (imageReference != null) {
                            CloseableImage image = imageReference.get();
                            if (image != null && image instanceof CloseableStaticBitmap) {
                                CloseableStaticBitmap closeableStaticBitmap = (CloseableStaticBitmap) image;
                                Bitmap bitmap = closeableStaticBitmap.getUnderlyingBitmap();
                                if (bitmap != null) {
                                    bitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true);
                                    iconBitmapDescriptor = BitmapDescriptorFactory.fromBitmap(bitmap);

                                    if (marker != null && iconBitmapDescriptor != null) {
                                        marker.setIcon(iconBitmapDescriptor);
                                    }
                                }
                            }
                        }
                    } finally {
                        dataSource.close();
                        if (imageReference != null) {
                            CloseableReference.closeSafely(imageReference);
                        }
                    }
                }
            };

    public OverlayMarker(ThemedReactContext context) {
        super(context);

        mContext = context;
        init();
    }

    public OverlayMarker(Context context, @Nullable AttributeSet attrs) {
        super(context);

        mContext = context;
        init();
    }

    public OverlayMarker(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context);
        mContext = context;
        init();
    }

    protected void init() {
        GenericDraweeHierarchy genericDraweeHierarchy = new GenericDraweeHierarchyBuilder(getResources())
                .setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER)
                .setFadeDuration(0)
                .build();
        imageHolder = DraweeHolder.create(genericDraweeHierarchy, getContext());
        imageHolder.onAttach();
    }

    @TargetApi(21)
    public OverlayMarker(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context);
    }


    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public LatLng getPosition() {
        return position;
    }

    public void setPosition(LatLng position) {
        Log.d("RNBaidudu", "Marker is setPosition:" + position.latitude + "  " + position.longitude);
        this.position = position;
        if (marker != null) {
            marker.setPosition(position);
        }
        if (this.mTag >= 0) {
            Intent intent = new Intent();
            intent.setAction("com.jimi.rn.kJMBaiduInfoWindowUpdateLocation");
            intent.putExtra("tag", this.mTag);
            intent.putExtra("latitude", position.latitude);
            intent.putExtra("longitude", position.longitude);
            intent.putExtra("visible", this.visible);
            if (this.marker != null && this.marker.getIcon() != null && this.marker.getIcon().getBitmap() != null) {
                intent.putExtra("iconHeight", this.marker.getIcon().getBitmap().getHeight());
            } else {
                intent.putExtra("iconHeight", -47);
            }

            mContext.sendBroadcast(intent);
        }
    }

    public BitmapDescriptor getIconBitmapDescriptor() {
        return iconBitmapDescriptor;
    }

    public void setIconBitmapDescriptor(BitmapDescriptor iconBitmapDescriptor) {
        this.iconBitmapDescriptor = iconBitmapDescriptor;
    }

    public Float getRotate() {
        return rotate;
    }

    public void setRotate(Float rotate) {
        this.rotate = rotate;
        if (marker != null) {
            marker.setRotate(rotate);
        }
    }

    public Boolean getFlat() {
        return flat;
    }

    public void setFlat(Boolean flat) {
        this.flat = flat;
        if (marker != null) {
            marker.setFlat(flat);
        }
    }

    public void setVisible(Boolean visible) {
        Log.d("RNBaidudu", "setVisible"+visible);
        this.visible = visible;
        if (marker != null) {
            marker.setVisible(visible);
          marker.setClickable(visible);
        }
        this.setPosition(this.position);
    }

    public Boolean getPerspective() {
        return perspective;
    }

    public void setPerspective(Boolean perspective) {
        this.perspective = perspective;
        if (marker != null) {
            marker.setPerspective(perspective);
        }
    }

    public void setIcon(String uri) {
        if (uri == null) {
            iconBitmapDescriptor = null;
        } else if (uri.startsWith("http://") || uri.startsWith("https://") ||
                uri.startsWith("file://") || uri.startsWith("asset://")) {
            ImageRequest imageRequest = ImageRequestBuilder
                    .newBuilderWithSource(Uri.parse(uri))
                    .build();
            ImagePipeline imagePipeline = Fresco.getImagePipeline();
            dataSource = imagePipeline.fetchDecodedImage(imageRequest, this);
            DraweeController controller = Fresco.newDraweeControllerBuilder()
                    .setImageRequest(imageRequest)
                    .setControllerListener(imageControllerListener)
                    .setOldController(imageHolder.getController())
                    .build();
            imageHolder.setController(controller);
        } else {
            iconBitmapDescriptor = getBitmapDescriptorByName(uri);

            if (marker != null && iconBitmapDescriptor != null) { //用于后期更换Marker图标
                marker.setIcon(iconBitmapDescriptor);
            }
        }
    }

    @Override
    public void addTopMap(BaiduMap baiduMap) {
        Log.d("RNBaidudu", "Marker is addTopMap");
        mBaiduMap = baiduMap;
        addOverlay(baiduMap);
    }

    @Override
    public void removeFromMap(BaiduMap baiduMap) {
        Log.d("RNBaidudu", "Marker is remove from map");
        if (mBaiduMap == baiduMap && marker != null) {
            marker.remove();
            marker = null;
            mBaiduMap = null;
            Log.d("RNBaidudu", "Marker remove end");
        }
    }

    private void addOverlay(BaiduMap baiduMap) {
        Log.d("RNBaidudu", "Marker is addOverlay:" + getTag());
        BitmapDescriptor icon = null;
        if (getIconBitmapDescriptor() != null) {
            icon = getIconBitmapDescriptor();
        }  else {
            icon = BitmapDescriptorFactory.fromResource(R.mipmap.icon_gcoding);
        }
        if (icon==null)return;

        MarkerOptions option = new MarkerOptions()
                .position(position)
                .title(getTitle())
                .alpha(getAlpha())
                .icon(icon);


        if (rotate != null) {
            option.rotate(rotate);
        }
        if (flat != null) {
            option.flat(flat);
        }
        if (perspective != null) {
            option.perspective(perspective);
        }
        option.visible(visible);
        setVisible(visible);

        marker = (Marker) baiduMap.addOverlay(option);
        marker.setClickable(visible);
        Log.d("RNBaidudu", "Marker is clickeanble:" + visible);
        Bundle bundle = new Bundle();
        bundle.putInt("tag", mTag);
        marker.setExtraInfo(bundle);

        // updateMark();

    }

    /* private void updateMark() {
         buildDrawingCache(true);
         Bitmap bitmap = getDrawingCache(true);
         if (bitmap != null) {
             BitmapDescriptor bitmapDescriptor = BitmapDescriptorFactory.fromBitmap(bitmap);
             marker.setIcon(bitmapDescriptor);
             marker.setVisible(true);
             destroyDrawingCache();
         }else {
             delayUpdate();
         }
     }
     private void delayUpdate() {
         if (updateThread != null) {
             updateThread.interrupt();
             updateThread = null;
         }
         updateThread = new Thread(() -> {
             try {
                 Thread.sleep(200);
                 updateMark();
             } catch (InterruptedException e) {
             }
         });
         updateThread.start();
     }*/
    private int getDrawableResourceByName(String name) {
        return getResources().getIdentifier(
                name,
                "drawable",
                getContext().getPackageName());
    }

    private BitmapDescriptor getBitmapDescriptorByName(String name) {
        int resId = getDrawableResourceByName(name);
        return BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeResource(getResources(), resId));
    }

    public void setmTag(int tag) {
        Log.d("RNBaidudu", "Marker setmTag: " + tag);
        this.mTag = tag;
        this.setPosition(this.position);
    }
}
