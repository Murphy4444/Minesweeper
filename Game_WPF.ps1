<#
.SYNOPSIS
Minesweeper Game

.NOTES
Author:         GKE
Creation Date:  01.02.2020
Creation Time:  23:15


#>

#region Prerequisites
Add-Type -AssemblyName PresentationFramework
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
        "Medium" { $Height = 15; $TileSize = 40; $Global:MinesTotal = 40; $FontSize = 10 }
        "Hard" { $Height = 25; $TileSize = 30; $Global:MinesTotal = 100; $FontSize = 7.5 }
        Default { $Difficulty = "Easy"; $Height = 10; $TileSize = 50; $Global:MinesTotal = 10; $FontSize = 15 }
    }

    # $Global:Stringbuilder = New-Object System.Text.StringBuilder

    # $Global:Stringbuilder.Append()

    $Global:XAML = @{ }

    $Global:XAML | Add-Member -MemberType NoteProperty -Name "XAML" -Value ""
    $Global:XAML | Add-Member -MemberType NoteProperty -Name "Width" -Value (($Height * $TileSize) + 25)
    $Global:XAML | Add-Member -MemberType NoteProperty -Name "Height" -Value (($Height * $TileSize) + 150)
    $Global:XAML | Add-Member -MemberType NoteProperty -Name "RowDefinitions" -Value ""
    $Global:XAML | Add-Member -MemberType NoteProperty -Name "ColumnDefinitions" -Value ""
    $Global:XAML | Add-Member -MemberType NoteProperty -Name "AllButtons" -Value ""
    
    [int]$Global:AllGoodFields = [Math]::Pow($Height, 2) - $MinesTotal
    
    $Global:AllFields = @()

    for ($y = 0; $y -lt $Height; $y++) {

        $XAML.ColumnDefinitions += @"
        <ColumnDefinition Width="$TileSize" />
"@
        $XAML.RowDefinitions += @"
        <RowDefinition Height="$TileSize" />
"@

        $Y_Pos = 5 + ($y * $TileSize)
        for ($x = 0; $x -lt $Height; $x++) {
            # $X_Pos = 5 + ($x * $TileSize)

            if (($x + $y) % 2 -eq 0) { $Color = "DarkGreen" }
            else { $Color = "Green" }

            $XAML_AllButtons += @" 
            <Button x:Name="$x.$y"
            Content="$x.$y"
                Grid.Column="$x"
                Grid.Row="$y"
                Background="$Color"
            />
"@


            
            # $Button.Text = "$x.$y"
            # $Button | Add-Member -MemberType NoteProperty -Name "X" -Value $x
            # $Button | Add-Member -MemberType NoteProperty -Name "Y" -Value $y
            # $Button | Add-Member -MemberType NoteProperty -Name "isMine" -Value $false
            # $Button | Add-Member -MemberType NoteProperty -Name "isFlagged" -Value $false
            # $Button | Add-Member -MemberType NoteProperty -Name "Adjacent" -Value ""
            # $Button | Add-Member -MemberType NoteProperty -Name "isUncovered" -Value $false
            # $Button | Add-Member -MemberType NoteProperty -Name "PrevColor" -Value $Color
            
            # $Button.add_Click( {
            #         Test-Field -Field $this -Height $Height
            #     })

            # $Button.Add_MouseDown( {
            #         if (!($this.isUncovered)) {
            #             if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Right ) {
            #                 $this.isFlagged = $this.isFlagged -xor $true
            #                 if ($this.isFlagged) { 
            #                     $this.BackColor = [System.Drawing.Color]::MediumPurple
            #                     $Global:MinesTotal--
            #                 }
            #                 else {
            #                     $this.BackColor = [System.Drawing.Color]::($this.PrevColor)
            #                     $Global:MinesTotal++
            #                 }
            #                 $FlagsRemaining.Text = $Global:MinesTotal
            #             }
            #         }
            #     })

        }
        # $Global:AllFields += , $Line
    }
    Set-Mines -AmountOfMines $MinesTotal

    Update-Adjacent -Height $Height
    
    $Zero_Y_Point = $Y_Pos + $TileSize + 15
    
    $Restart_Button = New-Object System.Windows.Forms.Button
    $Restart_Button.Size = New-Object System.Drawing.Size(100, 80)
    $Restart_Button.Location = New-Object System.Drawing.Size(5, $Zero_Y_Point)
    $Restart_Button.Name = "Button_Restart"
    $Restart_Button.Text = "Restart Game"
    $Global:Form.Controls.Add($Restart_Button) 

    $Restart_Button.add_Click( {
            $this.Parent.Hide()
            $this.Parent.Close()
            if ($null -ne $lb_Difficulty.SelectedItem ) { $NewDifficulty = $lb_Difficulty.SelectedItem }
            else { $NewDifficulty = $Difficulty }
            Start-MainForm -Difficulty $NewDifficulty
        })

    $lb_Difficulty = New-Object System.Windows.Forms.ListBox
    $lb_Difficulty.Location = New-Object System.Drawing.Point(110, $Zero_Y_Point)
    $lb_Difficulty.Size = New-Object System.Drawing.Size(100, 80)
    $lb_Difficulty.Font = [System.Drawing.Font]::new($Button.Font.FontFamily, 15)
    ForEach ($Diff in @("Easy", "Medium", "Hard")) {
        $lb_Difficulty.Items.Add($Diff) | Out-Null
    }
    
    # @("Easy", "Medium", "Hard") | ForEach-Object { $lb_Difficulty.Items.Add($_) | Out-Null }
    
    $lb_Difficulty.Height = 80
    $Global:Form.Controls.Add($lb_Difficulty)   
    
    $FlagColor = New-Object System.Windows.Forms.Label
    $FlagColor.Location = New-Object System.Drawing.Point(220, $Zero_Y_Point)
    $FlagColor.Size = New-Object System.Drawing.Size(25, 25)    
    $FlagColor.BackColor = [System.Drawing.Color]::MediumPurple
    $FlagColor.Text = ""
    $FlagColor.Font = [System.Drawing.Font]::new($Button.Font.FontFamily, 15)
    $Global:Form.Controls.Add($FlagColor)

    $FlagsRemaining = New-Object System.Windows.Forms.Label
    $FlagsRemaining.Location = New-Object System.Drawing.Point(250, $Zero_Y_Point)
    $FlagsRemaining.Size = New-Object System.Drawing.Size(50, 25)
    $FlagsRemaining.Text = $Global:MinesTotal
    $FlagsRemaining.Font = [System.Drawing.Font]::new($Button.Font.FontFamily, 15)
    $Global:Form.Controls.Add($FlagsRemaining)

    $TimerLabel = New-Object System.Windows.Forms.Label
    $TimerLabel.Location = New-Object System.Drawing.Point(250, ($Zero_Y_Point + 25))
    $TimerLabel.Text = "000"
    $TimerLabel.Font = [System.Drawing.Font]::new($Button.Font.FontFamily, 15)
    
    $Global:Time = 0

    # $Global:Timer.Stop()

    $Global:Timer = New-Object System.Windows.Forms.Timer
    $Global:Timer.Interval = 1000
    $Global:Timer.Enabled = $false
    $Global:Timer.Stop()
    $Global:Timer.add_tick( { 
            $Global:Time ++
            $NewText = "0" * (3 - ($Global:Time.ToString() -split "" | Where-Object { $_ -ne "" }).Count) + "$Global:Time"
            $TimerLabel.Text = $NewText
        })

    $Global:Form.Controls.Add($TimerLabel)

    [xml]$Global:XAML.XAML = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window"
    Title="Minesweeper"
    Height="$($Global:XAML.Height)"
    Width="$($Global:XAML.Width)">
    <Grid x:Name="Grid">
        <Grid.ColumnDefinitions>$XAML_ColumnDefinitions</Grid.ColumnDefinitions>
        <Grid.RowDefinitions>$XAML_RowDefinitions</Grid.RowDefinitions>
        $XAML_AllButtons
    </Grid>
</Window>
"@
    $Global:XAML.XAML = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window"
    <Grid x:Name="Grid">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto" />
            <ColumnDefinition Width="Auto" />
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Width="Auto" />
            <RowDefinition Width="Auto" />
        </Grid.RowDefinitions>
        <Button x:Name="Button1"
            Content="0.0"
            Grid.Column="1"
            Grid.Row="1"
        />
        <Button x:Name="Button2"
            Content="0.1"
            Grid.Column="1"
            Grid.Row="1"
        />
    </Grid>
</Window>
"@

    $Reader = (New-Object System.Xml.XmlNodeReader ([xml]$Global:XAML.XAML))
    $window = [Windows.Markup.XamlReader]::Load($Reader)
    $window.ShowDialog()

    $Global:Form.ShowDialog()
}

function Test-Field {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Button]$Field,
        [Parameter(Mandatory = $true)]
        [int]$Height
    )
    if (!($Global:Timer.Enabled)) {
        $Global:Timer.Start()
    }
    if ($Field.isMine) {
        $Global:Timer.Enabled = $false
        Disable-AllButtons
        Invoke-Boom -InitialMine $Field
    }
    elseif ($Field.isUncovered) { 
        # Do Nothing
    }
    else {
        Show-Field -Field $Field -Height $Height
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
            $Randomx = Get-Random -Minimum 0 -Maximum $LastElement
            $Randomy = Get-Random -Minimum 0 -Maximum $LastElement
        }
        while ($RandomHistory -contains @($Randomx, $Randomy))
        ($Global:AllFields[$Randomx][$Randomy]).isMine = $true
        $RandomHistory += @($Randomx, $Randomy)
    }
}

function Invoke-Boom {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Button]$InitialMine
    )

    $InitialMine.BackColor = [System.Drawing.Color]::Red
    $Global:Form.Update()
    Start-Sleep -Milliseconds 500
    $ToBeBlownUp = @()
    # $Global:AllFields | ForEach-Object { $ToBeBlownUp += $_ | Where-Object { $_.isMine -eq $true } }
    ForEach ($Fields in $Global:AllFields) {
        ForEach ($Field in $Fields) {
            if ($Field.isMine) {
                $ToBeBlownUp += $Field
            }
            if ($Field.isFlagged -and !($Field.isMine)) {
                $Field.BackColor = [System.Drawing.Color]::Pink
            }
        }
    }

    ForEach ($Field in $ToBeBlownUp) {
        $Field.BackColor = [System.Drawing.Color]::Red
        Start-Sleep -Milliseconds 100
        $Global:Form.Update()
    }
}

function Disable-AllButtons {
    ForEach ($Buttons in $Global:AllFields) {
        ForEach ($Button in $Buttons) {
            if ($Button.Name -ne "Button_Restart") {
                $Button.Enabled = $false
            }
        }
    }
}

function Update-Adjacent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$Height
    )
    for ($x = 0; $x -lt $Height; $x++) {
        for ($y = 0; $y -lt $Height; $y++) { 
            $AdjCount = 0
            for ($xadd = -1; $xadd -le 1; $xadd++) {
                for ($yadd = -1; $yadd -le 1; $yadd++) {
                    $fin_x = $x + $xadd
                    $fin_y = $y + $yadd
                    if ($fin_x -lt 0 -or $fin_y -lt 0 -or $fin_x -ge $Height -or $fin_y -ge $Height) { continue }
                    if (($Global:AllFields[$fin_y][$fin_x]).isMine) {
                        $AdjCount ++
                    }
                    if ($AdjCount -gt 0) {
                        ($Global:AllFields[$y][$x]).Adjacent = $AdjCount
                    }
                }
            }
        }
    }
}

function Show-Field {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Button]$Field,
        [Parameter(Mandatory = $true)]
        [int]$Height
    )
    
    # Show-Field -XPos $Field.X -YPos $Field.Y -Height $Height
    
    if (($Field.X + $Field.Y) % 2 -eq 0) {
        $Color = "LightGoldenrodYellow"
    } 
    else {
        $Color = "Ivory"
    }

    $Field.BackColor = [System.Drawing.Color]::$Color
    $Field.Text = "$($Field.Adjacent)"
    $Field.isUncovered = $true 

    $Global:AllGoodFields --

    if ($Global:AllGoodFields -le 0) {
        Disable-AllButtons
        $Global:Timer.Stop()
        [System.Windows.Forms.MessageBox]::Show("You Won!`n Your Time: $Global:Time")
    }
    
    $combx = @(-1, -1, -1, 0, 0, 1, 1, 1)
    $comby = @(-1, 0, 1, -1, 1, -1, 0, 1)
    # $combx = @(0, -1, 1, 0)
    # $comby = @(-1, 0, 0, 1)
    
    for ($index = 0; $index -lt $combx.Count; $index++) {
        $fin_x = $Field.X + $combx[$index]
        $fin_y = $Field.Y + $comby[$index]
        if ($fin_x -lt 0 -or $fin_y -lt 0 -or $fin_x -ge $Height -or $fin_y -ge $Height) { continue }
        if ($Field.Adjacent -eq "") {
            $NextField = $Global:AllFields[$fin_y][$fin_x]
            if (!($NextField.isUncovered) -and !($NextField.isMine)) {
                Show-Field -Field $NextField -Height $Height
            }
            # if (!($NextField.isMine)) {
            #     $NextField.Text = "$($NextField.Adjacent)"
            #     $NextField.BackColor = [System.Drawing.Color]::White
            # }
        }
    }
}

Start-MainForm



#endregion
