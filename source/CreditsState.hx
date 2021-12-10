package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
	['Vs Natsuki'],
	['Natsuki',		'silver',		'Coder/Diretor do projeto',					'https://youtube.com/channel/UCb0zxSI-rXrI1sJ9YPZxigg',	'0xFFFFFFFF'],
	['DC Wars',		'bright',		'Sprite Da Monika/Natsuki Phase 3',				'https://youtube.com/c/DCwars',		'0xFFC30085'],
	['EdwardThePro',		'lore',		'Musicas Do Capítulo 1 e 2/Artes',				'https://youtube.com/channel/UCi_aaLFl3-w0XvCDUAU5ZaA',		'0xFFC30085'],
	['GamesRF',		'polybiusproxy',		'Musicas Do Capítulo 3/Extras',				'https://youtube.com/c/GamesRF',		'0xFF6475F3'],
	['NuggetXD',			'discord',			'Ajuda',		'https://youtube.com/channel/UCo5DMnWx1GflsHMlM7RAVEQ',		'0xFF4494E6'],
        ['ToTs',		'silver',		'Ajuda',					'https://youtube.com/channel/UCwlks1N11lDGdG85V-Q8nEQ',	'0xFFFFFFFF'],
	['Haru Bits',		'bright',		'Beta Tester Do Mod',				'https://youtube.com/c/HaruBitsHelloDude',		'0xFFC30085'],
	[''],
	['Agradecimentos'],
	['Matheus Silver',			'riveroaken',		'Criador Da BS Engine',			'https://youtube.com/c/MatheusSilver',		'0xFFC30085'],

        
	['Team Salvato',		'shadowmario',		'Criadores Do DDLC',					'https://youtube.com/c/TeamSalvato',	'0xFFFFDD33'],
	['CelShader',			'riveroaken',		'Criador Do Mod DDTO',				'https://youtube.com/channel/UCm3eGs2etEOMzRX0iQ4QzqQ',		'0xFFC30085'],
	[''],

];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

			
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = Std.parseInt(creditsStuff[curSelected][4]);
		intendedColor = bg.color;
		changeSelection();
		addVirtualPad(UP_DOWN, A_B);
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  Std.parseInt(creditsStuff[curSelected][4]);
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
