/**
* ...
* @author Default
*/

package hails;

import hails.config.HailsConfig;

class HailsViewPhp extends HailsView {
	public override function render() {
		HailsPhpRenderer.includePhp(HailsConfig.getViewRoot() + "/" + 
			this.controllerId + "/" + this.actionId + ".php");
	}
}