import wx
from wx import xrc

class WxYaourt(wx.App):
	def OnInit(self):
		res = xrc.XmlResource('wxyaourt.xrc')
		self.frame = res.LoadFrame(None, 'MainWindow')
		self.frame.Show()
		return True

if __name__ == '__main__':
	app = WxYaourt()
	app.MainLoop()
