package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	var arrowSkin:String;
	var splashSkin:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var speed:Float = 1;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';

	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if(songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}
	}

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	/**
	 * Loads the song from a JSON file.
	 * @param jsonInput The song JSON.
	 * @param folder The song's folder.
	 * @param isEventFile If the song is an ``events.json``
	 * @param isMappedAnimJson If the song is a character's mapped animations. [``picospeaker.json``]
	 * @return SwagSong
	 */
	public static function loadFromJson(jsonInput:String, ?folder:String, ?isEventFile:Null<Bool> = false, ?isMappedAnimJson:Null<Bool> = false):SwagSong
	{
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);

		var songPath:String = 'charts/${formattedFolder}/difficulties/${jsonInput}';
		var eventsPath:String = 'charts/${formattedFolder}/events/events${FunkinSound.erectModeSuffix(false)}';
		var mappedAnimsPath:String = 'charts/${formattedFolder}/character-maps/${jsonInput}';

		/**
		 * Event JSONs check.
		 */
		if (isEventFile != null || !isEventFile)
		{
			if (isEventFile)
			{
				#if MODS_ALLOWED
				if (sys.FileSystem.exists(Paths.modsJson(eventsPath)) || sys.FileSystem.exists(Paths.json(eventsPath)))
				#else
				if (OpenFlAssets.exists(eventsPath))
				#end
				{
					songPath = eventsPath;
					#if (debug)
					FlxG.log.add('Loaded song events json of: ${formattedFolder.toUpperCase()}');
					#end
				}
			}
		}
		#if (debug)
		else
		{
			FlxG.log.add('Skipping event jsons check.');
		}
		#end

		/**
		 * Mapped character animations (Like 'picospeaker') JSONs check.
		 */
		if (isMappedAnimJson != null || !isMappedAnimJson)
		{
			if (isMappedAnimJson)
			{
				#if MODS_ALLOWED
				if (sys.FileSystem.exists(Paths.modsJson(mappedAnimsPath)) || sys.FileSystem.exists(Paths.json(mappedAnimsPath)))
				#else
				if (OpenFlAssets.exists(mappedAnimsPath))
				#end
				{
					songPath = mappedAnimsPath;
					#if (debug)
					FlxG.log.add('Loaded character mapped json \'${jsonInput}\' for: ${formattedFolder.toUpperCase()}');
					#end
				}
			}
		}
		#if (debug)
		else
		{
			FlxG.log.add('Skipping mapped character anims check.');
		}
		#end
		
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(songPath);
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if(rawJson == null) {
			#if sys
			rawJson = File.getContent(Paths.json(songPath)).trim();
			#else
			rawJson = Assets.getText(Paths.json(songPath)).trim();
			#end
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var songJson:Dynamic = parseJSONshit(rawJson);
		if(jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}

typedef SongDataJson = {
	var artist:String;
	var charter:String;
	var stringExtra:String;
}

class SongData
{
	public var artist:String;
	public var charter:String;
	public var stringExtra:String;

	/**
	 * Load a song's information/data file.
	 * @param song The song to load.
	 * @return SongDataJson
	 */
	public static function loadSongData(song:String):SongDataJson
	{
		if (song == null || song == '')
			return null;

		var j = null;

		final f:String = Paths.formatToSongPath(song);

		var p:String = 'charts/${f}/songdata/songdata${FunkinSound.erectModeSuffix(false)}';
		
		#if MODS_ALLOWED
		var m:String = Paths.modsJson(p);
		if (FileSystem.exists(m))
			j = File.getContent(m).trim();
		#end

		if (j == null)
			#if sys j = File.getContent(Paths.json(p).trim()); #else j = Assets.getText(Paths.json(p).trim()); #end

		while (!j.endsWith('}'))
			j = j.substr(0, j.length - 1);

		var sj:Dynamic = parseData(j);

		return sj;
	}

	public static function parseData(j:String):SongDataJson
	{
		var s:SongDataJson = cast Json.parse(j).song_data;
		return s;
	}
}
