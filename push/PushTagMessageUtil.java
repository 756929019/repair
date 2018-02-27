package org.water.push;

import org.apache.commons.lang.StringUtils;

import cn.jiguang.common.ClientConfig;
import cn.jiguang.common.ServiceHelper;
import cn.jiguang.common.connection.NativeHttpClient;
import cn.jpush.api.JPushClient;
import cn.jpush.api.push.PushResult;
import cn.jpush.api.push.model.Message;
import cn.jpush.api.push.model.Platform;
import cn.jpush.api.push.model.PushPayload;
import cn.jpush.api.push.model.audience.Audience;

public class PushTagMessageUtil {

	/*private static final String apiKey = "yGmIPGEG9zIGSWU0vO4U3ZwX";
	private static final String secretKey = "SOna8V2iLfTdipLuLZDjKTMvHFwQnwL6";*/

	private static final String MASTER_SECRET = "cd2afcc525632d0b9181a6a1";
	private static final String APP_KEY = "905af0c8d5a843b77de1309c";

	/**
	 * 推送消息
	 * */
	public static int PushReceiveMsg(String userid, String ChannelId,
			String clientId, String msg) {
		if (StringUtils.isEmpty(ChannelId)) {
			System.out.println("注册码不存在！");
			return 0;
		}

		try {
			ClientConfig clientConfig = ClientConfig.getInstance();

			ClientConfig config = ClientConfig.getInstance();
			config.setApnsProduction(true); // development env
			config.setTimeToLive(110); // 110秒

			JPushClient jpushClient = new JPushClient(MASTER_SECRET, APP_KEY,
					null, clientConfig);

			String authCode = ServiceHelper.getBasicAuthorization(APP_KEY,
					MASTER_SECRET);

			NativeHttpClient httpClient = new NativeHttpClient(authCode, null,
					clientConfig);

			PushPayload payload = PushPayload
					.newBuilder()
					.setPlatform(Platform.android())
					.setAudience(Audience.registrationId(ChannelId))
					.setMessage(Message.content(msg))
					.build();

			jpushClient.getPushClient().setHttpClient(httpClient);

			PushResult result = jpushClient.sendPush(payload);

			if (result.isResultOK()) {
				return 1;
			} else {
				System.out.println(result.sendno + "-" + result.msg_id + "-"
						+ result.statusCode);
				return 0;
			}
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}
}
