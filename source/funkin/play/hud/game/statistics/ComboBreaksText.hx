package funkin.play.hud.game.statistics;

import funkin.ui.display.FunkinText;

class ComboBreaksText extends FunkinText
{
	public var comboBreaksString:Null<String> = 'Misses';
	public var comboBreaksNum:Int = 0;

	public function new(X:Float, Y:Float):Void
	{
		super(X, Y, FlxG.width, "Combo Breaks: N/A", Constants.STATISTICS_FONT_SIZE, LEFT, true);

		this.borderSize = Constants.STATISTICS_BORDER_SIZE;

		setup(comboBreaksString, comboBreaksNum);
	}

	private function setup(txt:Null<String>, comboBreaks:Int):Void
	{
		this.text = 'Combo Breaks: ${comboBreaks}';
		if (txt != null) {
			this.text = '${txt}: ${comboBreaks}';
		}
	}

	public function updateComboBreaks():Void
	{
		if (!PlayState.instance.cpuControlled && !PlayState.instance.practiceMode && !PlayState.chartingMode)
		{
			setup(comboBreaksString, comboBreaksNum);
		}
		else
		{
			this.text = 'Combo Breaks: N/A';
			if (comboBreaksString != null && comboBreaksString != '') {
				this.text = '${comboBreaksString}: N/A';
			}
		}
	}
}