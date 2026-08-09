package dustin;

import flixel.addons.effects.FlxTrail;

class FunkinTrail extends FlxTrail {
    /**
	 * A function to add a specific number of sprites to the trail to increase its length.
	 *
	 * @param   amount  The amount of sprites to add to the trail.
	 */
	public function increaseLength(amount:Int):Void
	{
		// Can't create less than 1 sprite obviously
		if (amount <= 0)
		{
			return;
		}
		
		_trailLength += amount;
		
		// Create the trail sprites
		for (i in 0...amount)
		{
			final trailSprite = new FunkinSprite(0, 0);
			
			if (_graphic == null)
			{
				trailSprite.loadGraphicFromSprite(target);
			}
			else
			{
				trailSprite.loadGraphic(_graphic);
			}
            if (target.animateAtlas != null && target.atlasPath != null) {
				trailSprite.loadSprite(target.atlasPath);
                trailSprite.animation.copyFrom(target.animation);
            }
			trailSprite.exists = false;
			trailSprite.active = false;
			add(trailSprite);
			trailSprite.alpha = _transp;
			_transp -= _difference;
			trailSprite.solid = solid;
			
			if (trailSprite.alpha <= 0)
			{
				trailSprite.kill();
			}
		}
	}
}