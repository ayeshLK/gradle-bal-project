import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.file.DuplicatesStrategy
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

        project.tasks.register('updateTomlFiles') {
            def projectVersion = project.version
            def ballerinaVersion = project.ballerinaDistributionVersion
            def workspaceDir = project.projectDir

            doLast {
                workspaceDir.listFiles()
                        .findAll { it.isDirectory() && new File(it, "Ballerina.toml").exists() }
                        .each { dir ->
                            def buildConfigDir = new File("${project.rootDir}/build-config/resources/${dir.name}")
                            if (!buildConfigDir.exists()) return

                            project.copy {
                                from(buildConfigDir) {
                                    include '**/Ballerina.toml'
                                    filter { line ->
                                        line.replace('@toml.version@', projectVersion)
                                                .replace('@ballerina.version@', ballerinaVersion)
                                    }
                                }
                                into dir
                                duplicatesStrategy = DuplicatesStrategy.INCLUDE
                            }
                        }
            }
        }

        project.tasks.named('build') {
            dependsOn project.rootProject.tasks.named('verifyLocalBalVersion')
            dependsOn project.tasks.named('updateTomlFiles')
            dependsOn project.tasks.named('balBuild')
            dependsOn project.tasks.named('commitTomlFiles')

            it.mustRunAfter project.rootProject.tasks.named('verifyLocalBalVersion').get()
            it.mustRunAfter project.tasks.named('updateTomlFiles').get()
        }

        project.tasks.named('clean') {
            dependsOn project.tasks.named('balClean')
        }

        project.tasks.register('commitTomlFiles') {
            dependsOn project.tasks.named('updateTomlFiles')

            doLast {
                def isWindows = OperatingSystem.current().isWindows()

                project.projectDir.listFiles()
                        .findAll { dir ->
                            dir.isDirectory() && new File(dir, "Ballerina.toml").exists()
                        }
                        .each { dir ->

                            def ballerinaToml = dir.toPath().resolve("Ballerina.toml")
                            def dependenciesToml = dir.toPath().resolve("Dependencies.toml")
                            def commitMessage = "[Automated] Updating ${dir.name} package versions"

                            def gitCommand = isWindows
                                    ? "git add \"${ballerinaToml}\" \"${dependenciesToml}\" && git commit -m \"${commitMessage}\""
                                    : "git add \"${ballerinaToml}\" \"${dependenciesToml}\" && git commit -m '${commitMessage}'"

                            project.exec {
                                workingDir project.projectDir
                                ignoreExitValue true
                                commandLine(
                                        isWindows ? 'cmd' : 'sh',
                                        isWindows ? '/c' : '-c',
                                        gitCommand
                                )
                            }
                        }
            }
        }
    }
}
