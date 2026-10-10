#!/usr/bin/env python3
"""Generate the committed Xcode project using only Python's standard library."""
from pathlib import Path
import hashlib
import json
import plistlib
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
objects = {}
def uid(name): return hashlib.sha1(name.encode()).hexdigest()[:24].upper()
def add(object_key, isa, **values):
    objects[uid(object_key)] = {'isa': isa, **values}
    return uid(object_key)
def source_group(name, path, files):
    refs=[]
    for file in files:
        refs.append(add(name+'/'+file, 'PBXFileReference', lastKnownFileType='sourcecode.swift', path=file, sourceTree='<group>'))
    return add(name, 'PBXGroup', children=refs, path=path, sourceTree='<group>'),refs

afiles=sorted(p.name for p in (ROOT/'Arithmetics/App').glob('*.swift'))
cfiles=sorted(p.name for p in (ROOT/'Arithmetics/Core').glob('*.swift'))
ag, ar=source_group('App','App',afiles)
cg, cr=source_group('Core','Core',cfiles)
tg, tr=source_group('CoreTests','ArithmeticCoreTests',['ArithmeticCoreTests.swift'])
toptests=add('Tests','PBXGroup',children=[tg],path='Tests',sourceTree='<group>')
ug, ur=source_group('UITests','UITests',['ArithmeticsUITests.swift'])
asset=add('Assets','PBXFileReference',lastKnownFileType='folder.assetcatalog',path='Assets.xcassets',sourceTree='<group>')
privacy=add('Privacy','PBXFileReference',lastKnownFileType='text.xml',path='PrivacyInfo.xcprivacy',sourceTree='<group>')
info=add('Info','PBXFileReference',lastKnownFileType='text.plist.xml',path='Info.plist',sourceTree='<group>')
variants=[]
for filename in ['Localizable.strings','InfoPlist.strings']:
    refs=[add(filename+'/'+lang,'PBXFileReference',lastKnownFileType='text.plist.strings',name=lang,path=f'{lang}.lproj/{filename}',sourceTree='<group>') for lang in ['en','ru']]
    variants.append(add(filename,'PBXVariantGroup',children=refs,name=filename,sourceTree='<group>'))
rg=add('Resources','PBXGroup',children=[asset,privacy,info]+variants,path='Resources',sourceTree='<group>')
appgroup=add('ArithmeticsGroup','PBXGroup',children=[ag,cg,rg],path='Arithmetics',sourceTree='<group>')
products=[]
for name,ext in [('Arithmetics','app'),('ArithmeticsTests','xctest'),('ArithmeticsUITests','xctest')]:
    products.append(add(name+'Product','PBXFileReference',explicitFileType='wrapper.application' if ext=='app' else 'wrapper.cfbundle',includeInIndex=0,path=name+'.'+ext,sourceTree='BUILT_PRODUCTS_DIR'))
pg=add('Products','PBXGroup',children=products,name='Products',sourceTree='<group>')
rootgroup=add('Root','PBXGroup',children=[appgroup,toptests,ug,pg],sourceTree='<group>')

def phase(name, isa, refs):
    builds=[add(name+'/'+ref,'PBXBuildFile',fileRef=ref) for ref in refs]
    return add(name,isa,buildActionMask=2147483647,files=builds,runOnlyForDeploymentPostprocessing=0)
def config_list(name, settings):
    refs=[]
    for mode in ['Debug','Release']:
        values=dict(settings)
        if name=='Project':
            values.update({'SWIFT_OPTIMIZATION_LEVEL':'-Onone' if mode=='Debug' else '-O','DEBUG_INFORMATION_FORMAT':'dwarf' if mode=='Debug' else 'dwarf-with-dsym'})
            if mode=='Debug': values.update({'ENABLE_TESTABILITY':'YES','SWIFT_ACTIVE_COMPILATION_CONDITIONS':'DEBUG $(inherited)','GCC_PREPROCESSOR_DEFINITIONS':['DEBUG=1','$(inherited)']})
        refs.append(add(name+mode,'XCBuildConfiguration',buildSettings=values,name=mode))
    return add(name+'Configs','XCConfigurationList',buildConfigurations=refs,defaultConfigurationIsVisible=0,defaultConfigurationName='Release')
projectconfigs=config_list('Project',{'CLANG_ENABLE_MODULES':'YES','CLANG_ENABLE_OBJC_ARC':'YES','CLANG_WARN_BOOL_CONVERSION':'YES','CLANG_WARN_CONSTANT_CONVERSION':'YES','GCC_WARN_64_TO_32_BIT_CONVERSION':'YES','IPHONEOS_DEPLOYMENT_TARGET':'17.0','SDKROOT':'iphoneos','SWIFT_VERSION':'5.0','SWIFT_STRICT_CONCURRENCY':'complete','TARGETED_DEVICE_FAMILY':'1'})
common={'CODE_SIGN_STYLE':'Automatic','DEVELOPMENT_TEAM':'','PRODUCT_NAME':'$(TARGET_NAME)','CURRENT_PROJECT_VERSION':'1','MARKETING_VERSION':'1.0.0','SUPPORTED_PLATFORMS':'iphoneos iphonesimulator','SUPPORTS_MACCATALYST':'NO','SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD':'NO'}
appconfigs=config_list('Arithmetics',{**common,'PRODUCT_BUNDLE_IDENTIFIER':'com.tosoundra.arithmetics','INFOPLIST_FILE':'Arithmetics/Resources/Info.plist','ASSETCATALOG_COMPILER_APPICON_NAME':'AppIcon','LD_RUNPATH_SEARCH_PATHS':['$(inherited)','@executable_path/Frameworks'],'ENABLE_PREVIEWS':'YES'})
appphases=[phase('AppSources','PBXSourcesBuildPhase',ar+cr),phase('AppFrameworks','PBXFrameworksBuildPhase',[]),phase('AppResources','PBXResourcesBuildPhase',[asset,privacy]+variants)]
appid=add('ArithmeticsTarget','PBXNativeTarget',buildConfigurationList=appconfigs,buildPhases=appphases,buildRules=[],dependencies=[],name='Arithmetics',productName='Arithmetics',productReference=products[0],productType='com.apple.product-type.application')

targets=[appid]
for name,refs,index in [('ArithmeticsTests',tr,1),('ArithmeticsUITests',ur,2)]:
    proxy=add(name+'Proxy','PBXContainerItemProxy',containerPortal=uid('Project'),proxyType=1,remoteGlobalIDString=appid,remoteInfo='Arithmetics')
    dep=add(name+'Dependency','PBXTargetDependency',target=appid,targetProxy=proxy)
    settings={**common,'PRODUCT_BUNDLE_IDENTIFIER':'com.tosoundra.'+name.lower(),'GENERATE_INFOPLIST_FILE':'YES'}
    if index==1: settings.update({'BUNDLE_LOADER':'$(TEST_HOST)','TEST_HOST':'$(BUILT_PRODUCTS_DIR)/Arithmetics.app/Arithmetics','LD_RUNPATH_SEARCH_PATHS':['$(inherited)','@executable_path/Frameworks','@loader_path/Frameworks']})
    else: settings['TEST_TARGET_NAME']='Arithmetics'
    cfg=config_list(name,settings)
    tid=add(name+'Target','PBXNativeTarget',buildConfigurationList=cfg,buildPhases=[phase(name+'Sources','PBXSourcesBuildPhase',refs),phase(name+'Frameworks','PBXFrameworksBuildPhase',[]),phase(name+'Resources','PBXResourcesBuildPhase',[])],buildRules=[],dependencies=[dep],name=name,productName=name,productReference=products[index],productType='com.apple.product-type.bundle.unit-test' if index==1 else 'com.apple.product-type.bundle.ui-testing')
    targets.append(tid)
add('Project','PBXProject',attributes={'BuildIndependentTargetsInParallel':'YES','LastUpgradeCheck':'2600','TargetAttributes':{tid:{'CreatedOnToolsVersion':'26.0',**({'TestTargetID':appid} if tid!=appid else {})} for tid in targets}},buildConfigurationList=projectconfigs,compatibilityVersion='Xcode 14.0',developmentRegion='en',hasScannedForEncodings=0,knownRegions=['en','ru','Base'],mainGroup=rootgroup,productRefGroup=pg,projectDirPath='',projectRoot='',targets=targets)

def encode(value, indent=0):
    if isinstance(value,dict):
        return '{\n'+''.join('\t'*(indent+1)+json.dumps(str(k))+ ' = '+encode(v,indent+1)+';\n' for k,v in value.items())+'\t'*indent+'}'
    if isinstance(value,list): return '('+', '.join(encode(x,indent) for x in value)+')'
    if isinstance(value,int): return str(value)
    return json.dumps(value,ensure_ascii=False)
project={'archiveVersion':1,'classes':{},'objectVersion':56,'objects':objects,'rootObject':uid('Project')}
(ROOT/'Arithmetics.xcodeproj/project.pbxproj').write_text('// !$*UTF8*$!\n'+encode(project)+'\n')

scheme=ET.Element('Scheme',{'LastUpgradeVersion':'2600','version':'1.7'})
def buildable(parent,tid,name,ext):
    ET.SubElement(parent,'BuildableReference',{'BuildableIdentifier':'primary','BlueprintIdentifier':tid,'BuildableName':name+'.'+ext,'BlueprintName':name,'ReferencedContainer':'container:Arithmetics.xcodeproj'})
build=ET.SubElement(scheme,'BuildAction',{'parallelizeBuildables':'YES','buildImplicitDependencies':'YES'})
entries=ET.SubElement(build,'BuildActionEntries')
entry=ET.SubElement(entries,'BuildActionEntry',{'buildForTesting':'YES','buildForRunning':'YES','buildForProfiling':'YES','buildForArchiving':'YES','buildForAnalyzing':'YES'})
buildable(entry,appid,'Arithmetics','app')
test=ET.SubElement(scheme,'TestAction',{'buildConfiguration':'Debug','selectedDebuggerIdentifier':'Xcode.DebuggerFoundation.Debugger.LLDB','selectedLauncherIdentifier':'Xcode.IDEFoundation.Launcher.LLDB','shouldUseLaunchSchemeArgsEnv':'YES'})
testables=ET.SubElement(test,'Testables')
for tid,name in zip(targets[1:],['ArithmeticsTests','ArithmeticsUITests']):
    t=ET.SubElement(testables,'TestableReference',{'skipped':'NO','parallelizable':'NO'})
    buildable(t,tid,name,'xctest')
for action,config in [('LaunchAction','Debug'),('ProfileAction','Release')]:
    a=ET.SubElement(scheme,action,{'buildConfiguration':config,'useCustomWorkingDirectory':'NO','ignoresPersistentStateOnLaunch':'NO','debugDocumentVersioning':'YES',**({'selectedDebuggerIdentifier':'Xcode.DebuggerFoundation.Debugger.LLDB','selectedLauncherIdentifier':'Xcode.IDEFoundation.Launcher.LLDB','launchStyle':'0','allowLocationSimulation':'YES'} if action=='LaunchAction' else {})})
    run=ET.SubElement(a,'BuildableProductRunnable',{'runnableDebuggingMode':'0'})
    buildable(run,appid,'Arithmetics','app')
ET.SubElement(scheme,'AnalyzeAction',{'buildConfiguration':'Debug'})
ET.SubElement(scheme,'ArchiveAction',{'buildConfiguration':'Release','revealArchiveInOrganizer':'YES'})
ET.indent(scheme)
ET.ElementTree(scheme).write(ROOT/'Arithmetics.xcodeproj/xcshareddata/xcschemes/Arithmetics.xcscheme',encoding='utf-8',xml_declaration=True)

info={'CFBundleDevelopmentRegion':'$(DEVELOPMENT_LANGUAGE)','CFBundleDisplayName':'Arithmetics','CFBundleExecutable':'$(EXECUTABLE_NAME)','CFBundleIdentifier':'$(PRODUCT_BUNDLE_IDENTIFIER)','CFBundleInfoDictionaryVersion':'6.0','CFBundleName':'$(PRODUCT_NAME)','CFBundlePackageType':'APPL','CFBundleShortVersionString':'$(MARKETING_VERSION)','CFBundleVersion':'$(CURRENT_PROJECT_VERSION)','CFBundleLocalizations':['en','ru'],'LSRequiresIPhoneOS':True,'ITSAppUsesNonExemptEncryption':False,'UIApplicationSceneManifest':{'UIApplicationSupportsMultipleScenes':False},'UILaunchScreen':{},'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight']}
(ROOT/'Arithmetics/Resources/Info.plist').write_bytes(plistlib.dumps(info))
privacy={'NSPrivacyTracking':False,'NSPrivacyTrackingDomains':[],'NSPrivacyCollectedDataTypes':[],'NSPrivacyAccessedAPITypes':[{'NSPrivacyAccessedAPIType':'NSPrivacyAccessedAPICategoryUserDefaults','NSPrivacyAccessedAPITypeReasons':['CA92.1']}]}
(ROOT/'Arithmetics/Resources/PrivacyInfo.xcprivacy').write_bytes(plistlib.dumps(privacy))
print(f'Generated Xcode project: {len(objects)} objects, {len(ar+cr)} app Swift files, 3 targets.')
