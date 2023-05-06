function Send-PipeMessage($pipeName, $message) {
    $pipeExists = Get-ChildItem -Path "\\.\pipe\" | Where-Object { $_.Name -eq $pipeName } 
    if ($pipeExists.Length -gt 0) {
        $pipe = New-Object System.IO.Pipes.NamedPipeClientStream(".", $pipeName, [System.IO.Pipes.PipeDirection]::Out)
        $pipe.Connect()
        $streamWriter = New-Object System.IO.StreamWriter($pipe)
        $streamWriter.WriteLine($message)
        try {
            $streamWriter.Flush()
            $streamWriter.Dispose()
            $pipe.Dispose()
        }
        catch {
            # We don't care if the disposal fails, this is common with async pipes.
            # Also, this powershell script will terminate anyway.
        }
    }
}
function OnApplicationStarted() {
    $__logger.Info("OnApplicationStarted")
}

function OnApplicationStopped() {
    $__logger.Info("OnApplicationStopped")
}

function OnLibraryUpdated() {
    $__logger.Info("OnLibraryUpdated")
}

function OnGameStarting() {
    param($evnArgs)
    $__logger.Info("OnGameStarting $($evnArgs.Game)")
}

function OnGameStarted() {
    param($evnArgs)
    $game = $evnArgs.Game
    Send-PipeMessage -pipeName "PlayniteWatcher-OnStreamStart" -message $game.InstallDirectory
}

function OnGameStopped() {
    param($evnArgs)
    Send-PipeMessage -pipeName "PlayniteWatcher" -message "Terminate"
}

function OnGameInstalled() {
    param($evnArgs)
    $__logger.Info("OnGameInstalled $($evnArgs.Game)")
}

function OnGameUninstalled() {
    param($evnArgs)
    $__logger.Info("OnGameUninstalled $($evnArgs.Game)")
}

function OnGameSelected() {
    param($gameSelectionEventArgs)
    $__logger.Info("OnGameSelected $($gameSelectionEventArgs.OldValue) -> $($gameSelectionEventArgs.NewValue)")
}