import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import {
  AbilityPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { statfs } from '@kit.CoreFileKit';

const TAG = "DiskSpacePlusOhosPlugin";
const CHANNEL_NAME = 'disk_space_plus';

/** DiskSpacePlusOhosPlugin  */
export default class DiskSpacePlusOhosPlugin implements FlutterPlugin, AbilityAware, MethodCallHandler {
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToAbility(binding: AbilityPluginBinding) {
    this.channel?.setMethodCallHandler(this);
  }

  onDetachedFromAbility() {
  }

  private methodChannel: MethodChannel | null = null;
  private applicationContext: Context | null = null;

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.d(TAG, 'onAttachedToEngine packageInfo plugin')
    this.applicationContext = binding.getApplicationContext();
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.methodChannel.setMethodCallHandler(this);

  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    Log.d(TAG, 'onDetachedFromEngine packageInfo plugin')
    this.applicationContext = null;
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    Log.d(TAG, 'onMethodCall step in: ' + call.method);
    switch (call.method) {
      case "getTotalDiskSpace":
        let totalSize = this.getTotalDiskSpace();
        result.success(totalSize);
        break;
      case "getFreeDiskSpace":
        let freeSize = this.getFreeDiskSpace();
        result.success(freeSize);
        break;
      case "getFreeDiskSpaceForPath":
        let path = call.argument("path") as string;
        let freeSizeForPath = this.getFreeDiskSpaceForPath(path);
        result.success(freeSizeForPath);
        break;
      default:
        break;
    }
  }

  /**
   * Get total disk space
   * @returns free disk space in MB or null
   */
  getTotalDiskSpace(): number | null {
    try {
      let path = this.applicationContext?.filesDir;
      let bytes = statfs.getTotalSizeSync(path);
      return this.convertBytesToMegaBytes(bytes);
    } catch (err) {
      Log.e(TAG, "getTotalSizeSync failed with error message: " + err.message + ", error code: " + err.code);
      return null;
    }
  }

  /**
   * Get free disk space
   * @returns free disk space in MB or null
   */
  getFreeDiskSpace(): number | null {
    try {
      let path = this.applicationContext?.filesDir;
      let bytes = statfs.getFreeSizeSync(path);
      return this.convertBytesToMegaBytes(bytes);
    } catch (err) {
      Log.e(TAG, "getFreeSizeSync failed with error message: " + err.message + ", error code: " + err.code);
      return null;
    }
  }

  /**
   * Get free disk space for specific path
   * @param path
   * @returns free disk space for specific path in MB or null
   */
  getFreeDiskSpaceForPath(path: string): number | null {
    try {
      let bytes = statfs.getFreeSizeSync(path);
      return this.convertBytesToMegaBytes(bytes);
    } catch (err) {
      Log.e(TAG, "getFreeSizeSync failed on path '" + path + "' with error message: " + err.message + ", error code: " +
      err.code);
      return null;
    }
  }

  /**
   * convert from Bytes to MegaBytes
   * @param bytes
   * @returns mega bytes
   */
  convertBytesToMegaBytes(bytes: number): number {
    return parseFloat((bytes / 1024 / 1204).toFixed(2));
  }
}
