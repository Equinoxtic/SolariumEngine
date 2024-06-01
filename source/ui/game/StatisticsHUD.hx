package ui.game;

import flixel.FlxBasic;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import ui.game.statistics.*;

class StatisticsHUD extends FlxSpriteGroup
{
	private var instance:FlxBasic;

	private var scoreText:ScoreText;
	private var missesText:ComboBreaksText;
	private var accuracyText:AccuracyText;
	private var ratingText:RatingText;

	public function new(instance:FlxBasic, X:Float, Y:Float, ?scale:Float = 1.0):Void
	{
		super();

		if (instance == null)
		{
			instance = this;
		}

		this.instance = instance;

		#if (debug)
		FlxG.log.add('Created Statistics HUD.');
		#end

		scoreText = new ScoreText(X, Y);
		scoreText.scoreString = 'Score';
		scoreText.scoreNum = PlayState.instance.songScore;

		missesText = new ComboBreaksText(scoreText.x, scoreText.y + 25);
		missesText.comboBreaksString = 'Misses';
		missesText.comboBreaksNum = PlayState.instance.songMisses;

		accuracyText = new AccuracyText(missesText.x, missesText.y + 25);
		accuracyText.accuracyString = 'Accuracy';
		accuracyText.accuracyNum = Highscore.floorDecimal(PlayState.instance.ratingPercent * 100, 2);
		accuracyText.shouldRound = false;

		ratingText = new RatingText(accuracyText.x, accuracyText.y + 25);
		ratingText.ratingString = PlayState.instance.ratingFC;
		ratingText.rankingString = PlayState.instance.ranking;

		add(ratingText);
		add(accuracyText);
		add(missesText);
		add(scoreText);
	}

	public function setNumValues(songScore:Int, songMisses:Int, accuracy:Float, rating:String, ranking:String):Void
	{
		scoreText.scoreNum = songScore;
		missesText.comboBreaksNum = songMisses;
		accuracyText.accuracyNum = accuracy;
		ratingText.ratingString = rating;
		ratingText.rankingString = ranking;
	}

	public function updateNumValues():Void
	{
		scoreText.updateScore();
		missesText.updateComboBreaks();
		accuracyText.updateAccuracy();
		ratingText.updateRating();
	}

	public function updateStatistics(?autoSet:Bool = true):Void
	{
		if (autoSet)
		{
			setNumValues(
				PlayState.instance.songScore,
				PlayState.instance.songMisses,
				Highscore.floorDecimal(PlayState.instance.ratingPercent * 100, 2),
				PlayState.instance.ratingFC,
				PlayState.instance.ranking
			);
		}

		updateNumValues();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
