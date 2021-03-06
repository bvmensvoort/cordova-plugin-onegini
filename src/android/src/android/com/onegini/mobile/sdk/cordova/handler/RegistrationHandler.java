/*
 * Copyright (c) 2017-2018 Onegini B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.onegini.mobile.sdk.cordova.handler;

import static com.onegini.mobile.sdk.cordova.OneginiCordovaPluginConstants.EVENT_SUCCESS;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import com.onegini.mobile.sdk.android.handlers.OneginiRegistrationHandler;
import com.onegini.mobile.sdk.android.handlers.error.OneginiRegistrationError;
import com.onegini.mobile.sdk.android.model.entity.CustomInfo;
import com.onegini.mobile.sdk.android.model.entity.UserProfile;
import com.onegini.mobile.sdk.cordova.util.PluginResultBuilder;

public class RegistrationHandler implements OneginiRegistrationHandler {

  private CallbackContext callbackContext;

  public RegistrationHandler(CallbackContext callbackContext) {
    this.callbackContext = callbackContext;
  }

  public void setCallbackContext(final CallbackContext callbackContext) {
    this.callbackContext = callbackContext;
  }

  @Override
  public void onSuccess(final UserProfile userProfile, CustomInfo customInfo) {
    BrowserRegistrationRequestHandler.setBrowserRegistrationRequestCallbackContext(null);
    final PluginResult pluginResult = new PluginResultBuilder()
        .withSuccess()
        .withEvent(EVENT_SUCCESS)
        .withProfileId(userProfile)
        .withCustomInfo(customInfo)
        .build();

    sendPluginResult(pluginResult);
  }

  @Override
  public void onError(final OneginiRegistrationError oneginiRegistrationError) {
    PluginResult pluginResult = new PluginResultBuilder()
        .withError()
        .withOneginiError(oneginiRegistrationError)
        .build();

    sendPluginResult(pluginResult);
  }

  private void sendPluginResult(final PluginResult pluginResult) {
    if (!callbackContext.isFinished()) {
      callbackContext.sendPluginResult(pluginResult);
    }
  }

}
