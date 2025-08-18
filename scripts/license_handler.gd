extends VBoxContainer

func _ready() -> void:
	$LicenseBtnsHBC/GDLicenseBTN.button_down.connect(func (): $GDLicenseWND.show())
	$LicenseBtnsHBC/AppLicenseBTN.button_down.connect(func (): $AppLicenseWND.show())
	$LicenseBtnsHBC/FontLicenseBTN.button_down.connect(func (): $FontLicenseWND.show())
