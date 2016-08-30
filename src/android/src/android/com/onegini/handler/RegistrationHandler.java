package com.onegini.handler;

import java.util.HashMap;
import java.util.Map;

import org.apache.cordova.CallbackContext;
import org.json.JSONObject;

import com.onegini.mobile.android.sdk.handlers.OneginiAuthenticationHandler;
import com.onegini.mobile.android.sdk.handlers.OneginiRegistrationHandler;
import com.onegini.mobile.android.sdk.handlers.error.OneginiAuthenticationError;
import com.onegini.mobile.android.sdk.handlers.error.OneginiRegistrationError;
import com.onegini.mobile.android.sdk.model.entity.UserProfile;

public class RegistrationHandler implements OneginiRegistrationHandler {

  private CallbackContext callbackContext;

  public RegistrationHandler(CallbackContext callbackContext) {
    this.callbackContext = callbackContext;
  }

  @Override
  public void onSuccess(final UserProfile userProfile) {
    final Map<String, Object> userProfileMap = new HashMap<String, Object>();
    userProfileMap.put("profileId", userProfile.getProfileId());
    userProfileMap.put("isDefault", userProfile.isDefault());
    final JSONObject payload = new JSONObject(userProfileMap);
    callbackContext.success(payload);
  }

  @Override
  public void onError(final OneginiRegistrationError oneginiRegistrationError) {
    final Map<String, Object> errorMap = new HashMap<String, Object>();
    errorMap.put("type", oneginiRegistrationError.getErrorType());
    errorMap.put("description", oneginiRegistrationError.getErrorDescription());
    final JSONObject payload = new JSONObject(errorMap);
    callbackContext.error(payload);
  }
}
