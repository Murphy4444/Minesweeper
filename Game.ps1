<#
.SYNOPSIS
Minesweeper Game

.NOTES
Author:         GKE
Creation Date:  01.02.2020
Creation Time:  23:15


#>

#region Prerequisites

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

#endregion


#region Create Main Form

#region Form
function Start-MainForm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][ValidateSet("Easy", "Medium", "Hard")]
        [string]$Difficulty
    )



    switch ($Difficulty) {
        # "Easy" { $Height = 10; $TileSize = 16 }
        "Medium" { $Height = 15; $TileSize = 40; $MinesTotal = 40 }
        "Hard" { $Height = 25; $TileSize = 30; $MinesTotal = 100 }
        Default { $Height = 10; $TileSize = 50; $MinesTotal = 10 }
    }

    $Form = New-Object System.Windows.Forms.Form
    $Form.Width = ($Height * $TileSize) + 25
    $Form.Height = ($Height * $TileSize) + 305


    $Global:AllFields = @()

    for ($y = 0; $y -lt $Height; $y++) {
        $Y_Pos = 5 + ($y * $TileSize)
        $Line = @()
        for ($x = 0; $x -lt $Height; $x++) {
            $X_Pos = 5 + ($x * $TileSize)

            if (($x + $y) % 2 -eq 0) { $Color = "DarkGreen" }
            else { $Color = "Green" }

            $Button = New-Object System.Windows.Forms.Button
            $Button.Size = New-Object System.Drawing.Size($TileSize, $TileSize)
            $Button.Location = New-Object System.Drawing.Size($X_Pos, $Y_Pos)
            $Button.BackColor = [System.Drawing.Color]::$Color
            $Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            # $Button.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
            # $Button.FlatAppearance.BorderSize = .6
            $Button.Name = "Field_$x.$y"
            $Button.Text = "$x.$y"
            # $Button | Add-Member -MemberType NoteProperty -Name "X" -Value $x
            # $Button | Add-Member -MemberType NoteProperty -Name "Y" -Value $y
            $Button | Add-Member -MemberType NoteProperty -Name "isMine" -Value $false
            $Button | Add-Member -MemberType NoteProperty -Name "isFlagged" -Value $false
            
            $Button.add_Click( {
                    Test-Field -Field $this
                })
            
            
            $Line += $Button
                
            $Form.Controls.Add($Button)
        }
        $Global:AllFields += $Line
    }
    
    Set-Mines -AmountOfMines $MinesTotal
    $Zero_Y_Point = $Y_Pos + $TileSize
    
    $Restart_Button = New-Object System.Windows.Forms.Button
    $Restart_Button.Size = New-Object System.Drawing.Size(100, 75)
    $Restart_Button.Location = New-Object System.Drawing.Size(5, $Zero_Y_Point)
    $Restart_Button.Name = "Button_Restart"
    $Restart_Button.Text = "Restart Game"
    $Form.Controls.Add($Restart_Button)
    
    $Form.ShowDialog()
}

function Test-Field {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Button]$Field
    )

    if ($Field.isMine) {
        Disable-AllButtons
        Invoke-Boom -InitialMine $Field
    }
    else {
        $Field.BackColor = [System.Drawing.Color]::White
    }

}

function Set-Mines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $AmountOfMines
    )
    $LastElement = $Global:AllFields.Count - 1 
    $RandomHistory = @()
    for ($i = 0; $i -lt $AmountOfMines; $i++) {
        do {
            $Random = Get-Random -Minimum 0 -Maximum $LastElement
        }
        while ($RandomHistory -contains $Random)
        $SetMine = $Global:AllFields[$Random]
        $SetMine.isMine = $true
        $RandomHistory += $Random
    }
}

function Invoke-Boom {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Button]$InitialMine
    )

    $InitialMine.BackColor = [System.Drawing.Color]::Red
    $Form.Update()
    Start-Sleep 1.5

    $ToBeBlownUp = $Global:AllFields | Where-Object { $_.isMine -eq $true }
    ForEach ($Field in $ToBeBlownUp) {
        $Field.BackColor = [System.Drawing.Color]::Red
        $Form.Update()
        Start-Sleep .5
    }

}

function Disable-AllButtons {
    ForEach ($Button in $Global:AllFields) {
        $Button.Enabled = $false
    }
}


Start-MainForm -Difficulty Easy


#endregion


#endregion