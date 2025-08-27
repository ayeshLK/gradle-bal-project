import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.tasks.Exec
import org.gradle.api.tasks.Copy
import org.gradle.internal.os.OperatingSystem
import BalUtils

class WebsubhubBallerinaComponentPlugin implements Plugin<Project> {
    void apply(Project project) {
        project.apply plugin: 'base'

        project.tasks.register('balBuild', Exec) {
            commandLine BalUtils.executeBalCommand('build')
        }

        project.tasks.register('balClean', Exec) {
            commandLine BalUtils.executeBalCommand('clean')
        }

        project.tasks.register('updateTomlFiles', Copy) {
            def componentName = project.name
            def buildConfigDir = new File("${project.rootDir}/build-config/resources/${componentName}")
            def componentDirectory = project.projectDir
            def projectVersion = project.version
            from(buildConfigDir) {
                include '**/*.toml'
                filter {
                    line ->
                    line.replace('@toml.version@', projectVersion)
                }
            }
            into componentDirectory

            inputs.files project.fileTree(buildConfigDir)
            inputs.property('projectVersion', projectVersion)
            outputs.files project.fileTree(componentDirectory) {
                include '**/*.toml'
            }
        }

        project.tasks.named('build') {
            dependsOn project.rootProject.tasks.named('verifyLocalBalVersion')
            dependsOn project.tasks.named('updateTomlFiles')
            dependsOn project.tasks.named('balBuild')

            it.mustRunAfter project.rootProject.tasks.named('verifyLocalBalVersion').get()
            it.mustRunAfter project.tasks.named('updateTomlFiles').get()
        }

        project.tasks.named('clean') {
            dependsOn project.tasks.named('balClean')
        }
    }
}
