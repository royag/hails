/**
* ...
* @author Default
*/

package hails;

import config.HailsConfig;

class HailsViewPhp extends HailsView {
	public override function render() {
		HailsPhpRenderer.includePhp(HailsConfig.phpViewRoot + "/" + 
			this.controllerId + "/" + this.actionId + ".php");
	}
}