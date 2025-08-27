import org.gradle.internal.os.OperatingSystem

class BalUtils {
    static def executeBalCommand(String command) {
        if (OperatingSystem.current().isWindows()) {
            return ['cmd', '/c', "bal.bat ${command}"]
        } else {
            return ['sh', '-c', "bal ${command}"]
        }
    }
}