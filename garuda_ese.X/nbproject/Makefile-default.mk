#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=mkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=elf
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/garuda_ese.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/garuda_ese.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

ifeq ($(COMPARE_BUILD), true)
COMPARISON_BUILD=-mafrlcsj
else
COMPARISON_BUILD=
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=foc/an1078_motor.c foc/an1078_smc.c foc/back_emf_obs.c foc/clarke.c foc/flux_estimator.c foc/foc_v2_control.c foc/foc_v2_detect.c foc/foc_v2_observer.c foc/foc_v2_pi.c foc/foc_v3_control.c foc/foc_v3_smo.c foc/mxlemming_obs.c foc/park.c foc/pi_controller.c foc/pll_estimator.c foc/smo_observer.c foc/svpwm.c garuda_service.c gsp/gsp.c gsp/gsp_commands.c gsp/gsp_params.c gsp/gsp_snapshot.c hal/board_service.c hal/clock.c hal/device_config.c hal/eeprom.c hal/hal_adc.c hal/hal_ata6847.c hal/hal_input_capture.c hal/hal_pwm.c hal/hal_spi.c hal/hal_timer.c hal/hal_zcd.c hal/port_config.c hal/timer1.c hal/uart1.c input/rx_decode.c learn/adaptation.c learn/commission.c learn/health.c learn/learn_service.c learn/quality.c learn/ring_buffer.c main.c motor/bemf_zc.c motor/commutation.c motor/hwzc.c motor/pi.c motor/speed_pi.c motor/startup.c scope/scope_burst.c x2cscope/diagnostics.c

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/foc/an1078_motor.o ${OBJECTDIR}/foc/an1078_smc.o ${OBJECTDIR}/foc/back_emf_obs.o ${OBJECTDIR}/foc/clarke.o ${OBJECTDIR}/foc/flux_estimator.o ${OBJECTDIR}/foc/foc_v2_control.o ${OBJECTDIR}/foc/foc_v2_detect.o ${OBJECTDIR}/foc/foc_v2_observer.o ${OBJECTDIR}/foc/foc_v2_pi.o ${OBJECTDIR}/foc/foc_v3_control.o ${OBJECTDIR}/foc/foc_v3_smo.o ${OBJECTDIR}/foc/mxlemming_obs.o ${OBJECTDIR}/foc/park.o ${OBJECTDIR}/foc/pi_controller.o ${OBJECTDIR}/foc/pll_estimator.o ${OBJECTDIR}/foc/smo_observer.o ${OBJECTDIR}/foc/svpwm.o ${OBJECTDIR}/garuda_service.o ${OBJECTDIR}/gsp/gsp.o ${OBJECTDIR}/gsp/gsp_commands.o ${OBJECTDIR}/gsp/gsp_params.o ${OBJECTDIR}/gsp/gsp_snapshot.o ${OBJECTDIR}/hal/board_service.o ${OBJECTDIR}/hal/clock.o ${OBJECTDIR}/hal/device_config.o ${OBJECTDIR}/hal/eeprom.o ${OBJECTDIR}/hal/hal_adc.o ${OBJECTDIR}/hal/hal_ata6847.o ${OBJECTDIR}/hal/hal_input_capture.o ${OBJECTDIR}/hal/hal_pwm.o ${OBJECTDIR}/hal/hal_spi.o ${OBJECTDIR}/hal/hal_timer.o ${OBJECTDIR}/hal/hal_zcd.o ${OBJECTDIR}/hal/port_config.o ${OBJECTDIR}/hal/timer1.o ${OBJECTDIR}/hal/uart1.o ${OBJECTDIR}/input/rx_decode.o ${OBJECTDIR}/learn/adaptation.o ${OBJECTDIR}/learn/commission.o ${OBJECTDIR}/learn/health.o ${OBJECTDIR}/learn/learn_service.o ${OBJECTDIR}/learn/quality.o ${OBJECTDIR}/learn/ring_buffer.o ${OBJECTDIR}/main.o ${OBJECTDIR}/motor/bemf_zc.o ${OBJECTDIR}/motor/commutation.o ${OBJECTDIR}/motor/hwzc.o ${OBJECTDIR}/motor/pi.o ${OBJECTDIR}/motor/speed_pi.o ${OBJECTDIR}/motor/startup.o ${OBJECTDIR}/scope/scope_burst.o ${OBJECTDIR}/x2cscope/diagnostics.o
POSSIBLE_DEPFILES=${OBJECTDIR}/foc/an1078_motor.o.d ${OBJECTDIR}/foc/an1078_smc.o.d ${OBJECTDIR}/foc/back_emf_obs.o.d ${OBJECTDIR}/foc/clarke.o.d ${OBJECTDIR}/foc/flux_estimator.o.d ${OBJECTDIR}/foc/foc_v2_control.o.d ${OBJECTDIR}/foc/foc_v2_detect.o.d ${OBJECTDIR}/foc/foc_v2_observer.o.d ${OBJECTDIR}/foc/foc_v2_pi.o.d ${OBJECTDIR}/foc/foc_v3_control.o.d ${OBJECTDIR}/foc/foc_v3_smo.o.d ${OBJECTDIR}/foc/mxlemming_obs.o.d ${OBJECTDIR}/foc/park.o.d ${OBJECTDIR}/foc/pi_controller.o.d ${OBJECTDIR}/foc/pll_estimator.o.d ${OBJECTDIR}/foc/smo_observer.o.d ${OBJECTDIR}/foc/svpwm.o.d ${OBJECTDIR}/garuda_service.o.d ${OBJECTDIR}/gsp/gsp.o.d ${OBJECTDIR}/gsp/gsp_commands.o.d ${OBJECTDIR}/gsp/gsp_params.o.d ${OBJECTDIR}/gsp/gsp_snapshot.o.d ${OBJECTDIR}/hal/board_service.o.d ${OBJECTDIR}/hal/clock.o.d ${OBJECTDIR}/hal/device_config.o.d ${OBJECTDIR}/hal/eeprom.o.d ${OBJECTDIR}/hal/hal_adc.o.d ${OBJECTDIR}/hal/hal_ata6847.o.d ${OBJECTDIR}/hal/hal_input_capture.o.d ${OBJECTDIR}/hal/hal_pwm.o.d ${OBJECTDIR}/hal/hal_spi.o.d ${OBJECTDIR}/hal/hal_timer.o.d ${OBJECTDIR}/hal/hal_zcd.o.d ${OBJECTDIR}/hal/port_config.o.d ${OBJECTDIR}/hal/timer1.o.d ${OBJECTDIR}/hal/uart1.o.d ${OBJECTDIR}/input/rx_decode.o.d ${OBJECTDIR}/learn/adaptation.o.d ${OBJECTDIR}/learn/commission.o.d ${OBJECTDIR}/learn/health.o.d ${OBJECTDIR}/learn/learn_service.o.d ${OBJECTDIR}/learn/quality.o.d ${OBJECTDIR}/learn/ring_buffer.o.d ${OBJECTDIR}/main.o.d ${OBJECTDIR}/motor/bemf_zc.o.d ${OBJECTDIR}/motor/commutation.o.d ${OBJECTDIR}/motor/hwzc.o.d ${OBJECTDIR}/motor/pi.o.d ${OBJECTDIR}/motor/speed_pi.o.d ${OBJECTDIR}/motor/startup.o.d ${OBJECTDIR}/scope/scope_burst.o.d ${OBJECTDIR}/x2cscope/diagnostics.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/foc/an1078_motor.o ${OBJECTDIR}/foc/an1078_smc.o ${OBJECTDIR}/foc/back_emf_obs.o ${OBJECTDIR}/foc/clarke.o ${OBJECTDIR}/foc/flux_estimator.o ${OBJECTDIR}/foc/foc_v2_control.o ${OBJECTDIR}/foc/foc_v2_detect.o ${OBJECTDIR}/foc/foc_v2_observer.o ${OBJECTDIR}/foc/foc_v2_pi.o ${OBJECTDIR}/foc/foc_v3_control.o ${OBJECTDIR}/foc/foc_v3_smo.o ${OBJECTDIR}/foc/mxlemming_obs.o ${OBJECTDIR}/foc/park.o ${OBJECTDIR}/foc/pi_controller.o ${OBJECTDIR}/foc/pll_estimator.o ${OBJECTDIR}/foc/smo_observer.o ${OBJECTDIR}/foc/svpwm.o ${OBJECTDIR}/garuda_service.o ${OBJECTDIR}/gsp/gsp.o ${OBJECTDIR}/gsp/gsp_commands.o ${OBJECTDIR}/gsp/gsp_params.o ${OBJECTDIR}/gsp/gsp_snapshot.o ${OBJECTDIR}/hal/board_service.o ${OBJECTDIR}/hal/clock.o ${OBJECTDIR}/hal/device_config.o ${OBJECTDIR}/hal/eeprom.o ${OBJECTDIR}/hal/hal_adc.o ${OBJECTDIR}/hal/hal_ata6847.o ${OBJECTDIR}/hal/hal_input_capture.o ${OBJECTDIR}/hal/hal_pwm.o ${OBJECTDIR}/hal/hal_spi.o ${OBJECTDIR}/hal/hal_timer.o ${OBJECTDIR}/hal/hal_zcd.o ${OBJECTDIR}/hal/port_config.o ${OBJECTDIR}/hal/timer1.o ${OBJECTDIR}/hal/uart1.o ${OBJECTDIR}/input/rx_decode.o ${OBJECTDIR}/learn/adaptation.o ${OBJECTDIR}/learn/commission.o ${OBJECTDIR}/learn/health.o ${OBJECTDIR}/learn/learn_service.o ${OBJECTDIR}/learn/quality.o ${OBJECTDIR}/learn/ring_buffer.o ${OBJECTDIR}/main.o ${OBJECTDIR}/motor/bemf_zc.o ${OBJECTDIR}/motor/commutation.o ${OBJECTDIR}/motor/hwzc.o ${OBJECTDIR}/motor/pi.o ${OBJECTDIR}/motor/speed_pi.o ${OBJECTDIR}/motor/startup.o ${OBJECTDIR}/scope/scope_burst.o ${OBJECTDIR}/x2cscope/diagnostics.o

# Source Files
SOURCEFILES=foc/an1078_motor.c foc/an1078_smc.c foc/back_emf_obs.c foc/clarke.c foc/flux_estimator.c foc/foc_v2_control.c foc/foc_v2_detect.c foc/foc_v2_observer.c foc/foc_v2_pi.c foc/foc_v3_control.c foc/foc_v3_smo.c foc/mxlemming_obs.c foc/park.c foc/pi_controller.c foc/pll_estimator.c foc/smo_observer.c foc/svpwm.c garuda_service.c gsp/gsp.c gsp/gsp_commands.c gsp/gsp_params.c gsp/gsp_snapshot.c hal/board_service.c hal/clock.c hal/device_config.c hal/eeprom.c hal/hal_adc.c hal/hal_ata6847.c hal/hal_input_capture.c hal/hal_pwm.c hal/hal_spi.c hal/hal_timer.c hal/hal_zcd.c hal/port_config.c hal/timer1.c hal/uart1.c input/rx_decode.c learn/adaptation.c learn/commission.c learn/health.c learn/learn_service.c learn/quality.c learn/ring_buffer.c main.c motor/bemf_zc.c motor/commutation.c motor/hwzc.c motor/pi.c motor/speed_pi.c motor/startup.c scope/scope_burst.c x2cscope/diagnostics.c



CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk ${DISTDIR}/garuda_ese.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=33AK256MC506
MP_LINKER_FILE_OPTION=,--script=p33AK256MC506.gld
# ------------------------------------------------------------------------------------
# Rules for buildStep: compile
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/foc/an1078_motor.o: foc/an1078_motor.c  .generated_files/flags/default/fcccc056c62450cca718ad66b1ea369be359d38a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/an1078_motor.o.d 
	@${RM} ${OBJECTDIR}/foc/an1078_motor.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_motor.c  -o ${OBJECTDIR}/foc/an1078_motor.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_motor.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/an1078_smc.o: foc/an1078_smc.c  .generated_files/flags/default/b6437e77511040dcdecb11533e1d0e24a8e26971 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/an1078_smc.o.d 
	@${RM} ${OBJECTDIR}/foc/an1078_smc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_smc.c  -o ${OBJECTDIR}/foc/an1078_smc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_smc.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/back_emf_obs.o: foc/back_emf_obs.c  .generated_files/flags/default/7ba405d28ad2cf4ddd47f736d668be305335e332 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/back_emf_obs.o.d 
	@${RM} ${OBJECTDIR}/foc/back_emf_obs.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/back_emf_obs.c  -o ${OBJECTDIR}/foc/back_emf_obs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/back_emf_obs.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/clarke.o: foc/clarke.c  .generated_files/flags/default/c1f20786ef74acb8e998c18930948cdb2f977d5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/clarke.o.d 
	@${RM} ${OBJECTDIR}/foc/clarke.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/clarke.c  -o ${OBJECTDIR}/foc/clarke.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/clarke.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/flux_estimator.o: foc/flux_estimator.c  .generated_files/flags/default/2fab4f64b8c25a784b99e8550300345a425c9e33 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/flux_estimator.o.d 
	@${RM} ${OBJECTDIR}/foc/flux_estimator.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/flux_estimator.c  -o ${OBJECTDIR}/foc/flux_estimator.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/flux_estimator.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_control.o: foc/foc_v2_control.c  .generated_files/flags/default/dfcd7975b638432dbe68ee3dca3006084355f384 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_control.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_control.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_control.c  -o ${OBJECTDIR}/foc/foc_v2_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_control.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_detect.o: foc/foc_v2_detect.c  .generated_files/flags/default/c15a7b174d6beb4a1129ff017a08f4233906225d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_detect.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_detect.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_detect.c  -o ${OBJECTDIR}/foc/foc_v2_detect.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_detect.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_observer.o: foc/foc_v2_observer.c  .generated_files/flags/default/bca81892bbe5931c6736b4f2ffd03c69168f5cff .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_observer.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_observer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_observer.c  -o ${OBJECTDIR}/foc/foc_v2_observer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_observer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_pi.o: foc/foc_v2_pi.c  .generated_files/flags/default/faec989522b5ec9e9579ab051e269b6eeee12c13 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_pi.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_pi.c  -o ${OBJECTDIR}/foc/foc_v2_pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_pi.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v3_control.o: foc/foc_v3_control.c  .generated_files/flags/default/e0562d806854308e7c50bf19e70da859b9ce08ed .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v3_control.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v3_control.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v3_control.c  -o ${OBJECTDIR}/foc/foc_v3_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v3_control.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v3_smo.o: foc/foc_v3_smo.c  .generated_files/flags/default/c0f066ccbdac885b2d4a5b54a72c7d291294c261 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v3_smo.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v3_smo.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v3_smo.c  -o ${OBJECTDIR}/foc/foc_v3_smo.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v3_smo.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/mxlemming_obs.o: foc/mxlemming_obs.c  .generated_files/flags/default/bbca856dd179110a72075ca95a7cd0f2f9b4ce69 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/mxlemming_obs.o.d 
	@${RM} ${OBJECTDIR}/foc/mxlemming_obs.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/mxlemming_obs.c  -o ${OBJECTDIR}/foc/mxlemming_obs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/mxlemming_obs.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/park.o: foc/park.c  .generated_files/flags/default/56b40ff5456a0721a2e4f87c3366241ce9f235a5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/park.o.d 
	@${RM} ${OBJECTDIR}/foc/park.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/park.c  -o ${OBJECTDIR}/foc/park.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/park.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/pi_controller.o: foc/pi_controller.c  .generated_files/flags/default/28c36b1d65445a78271a7d6104a2654b3ac65358 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/pi_controller.o.d 
	@${RM} ${OBJECTDIR}/foc/pi_controller.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/pi_controller.c  -o ${OBJECTDIR}/foc/pi_controller.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/pi_controller.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/pll_estimator.o: foc/pll_estimator.c  .generated_files/flags/default/29ff841dbc72d319f208cd47b025d46b4bfb1eca .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/pll_estimator.o.d 
	@${RM} ${OBJECTDIR}/foc/pll_estimator.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/pll_estimator.c  -o ${OBJECTDIR}/foc/pll_estimator.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/pll_estimator.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/smo_observer.o: foc/smo_observer.c  .generated_files/flags/default/3004233cb0e35eac8a786d8fa731ef748d343bf5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/smo_observer.o.d 
	@${RM} ${OBJECTDIR}/foc/smo_observer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/smo_observer.c  -o ${OBJECTDIR}/foc/smo_observer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/smo_observer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/svpwm.o: foc/svpwm.c  .generated_files/flags/default/77d782cbd38afea4ee5c3b065921ecae897058ab .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/svpwm.o.d 
	@${RM} ${OBJECTDIR}/foc/svpwm.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/svpwm.c  -o ${OBJECTDIR}/foc/svpwm.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/svpwm.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/garuda_service.o: garuda_service.c  .generated_files/flags/default/638a93f73c81e791d2cfee65fc3889508547f9a5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/garuda_service.o.d 
	@${RM} ${OBJECTDIR}/garuda_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  garuda_service.c  -o ${OBJECTDIR}/garuda_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/garuda_service.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp.o: gsp/gsp.c  .generated_files/flags/default/121ea2afff5f48ec02f011df2ebbcc06e3dce1b1 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp.c  -o ${OBJECTDIR}/gsp/gsp.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_commands.o: gsp/gsp_commands.c  .generated_files/flags/default/ebdbb3d8563f140f9f36410d2e7132b86a808392 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_commands.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_commands.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_commands.c  -o ${OBJECTDIR}/gsp/gsp_commands.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_commands.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_params.o: gsp/gsp_params.c  .generated_files/flags/default/454b4cfdef21fc013330cd2e409139a06cab4fd4 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_params.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_params.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_params.c  -o ${OBJECTDIR}/gsp/gsp_params.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_params.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_snapshot.o: gsp/gsp_snapshot.c  .generated_files/flags/default/ea19533fde9f2832cbbcaa85f38a8d1275bce31c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_snapshot.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_snapshot.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_snapshot.c  -o ${OBJECTDIR}/gsp/gsp_snapshot.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_snapshot.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/board_service.o: hal/board_service.c  .generated_files/flags/default/d936dc093d70c244399fa2e21ebd7fb88a977a9e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/board_service.o.d 
	@${RM} ${OBJECTDIR}/hal/board_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/board_service.c  -o ${OBJECTDIR}/hal/board_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/board_service.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/clock.o: hal/clock.c  .generated_files/flags/default/4b774521517ad7c1188afb6e74900f9b87d462fe .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/clock.o.d 
	@${RM} ${OBJECTDIR}/hal/clock.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/clock.c  -o ${OBJECTDIR}/hal/clock.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/clock.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/device_config.o: hal/device_config.c  .generated_files/flags/default/f592d95b74c08fb732f172ec5f0c3989842ae193 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/device_config.o.d 
	@${RM} ${OBJECTDIR}/hal/device_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/device_config.c  -o ${OBJECTDIR}/hal/device_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/device_config.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/eeprom.o: hal/eeprom.c  .generated_files/flags/default/8645ad612f77197617ddcdecfdae0f1987efb446 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/eeprom.o.d 
	@${RM} ${OBJECTDIR}/hal/eeprom.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/eeprom.c  -o ${OBJECTDIR}/hal/eeprom.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/eeprom.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_adc.o: hal/hal_adc.c  .generated_files/flags/default/3818fc885dccf8f7f5ad3b3a9105c26fad081534 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_adc.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_adc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_adc.c  -o ${OBJECTDIR}/hal/hal_adc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_adc.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_ata6847.o: hal/hal_ata6847.c  .generated_files/flags/default/270163cbc41ba9c0b863f9b8aee6ea8652805e94 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_ata6847.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_ata6847.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_ata6847.c  -o ${OBJECTDIR}/hal/hal_ata6847.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_ata6847.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_input_capture.o: hal/hal_input_capture.c  .generated_files/flags/default/ff6fd5c5b39d3d3709bbb9e0464d24f53e116719 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_input_capture.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_input_capture.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_input_capture.c  -o ${OBJECTDIR}/hal/hal_input_capture.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_input_capture.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_pwm.o: hal/hal_pwm.c  .generated_files/flags/default/111fca44036fe6b22a610721dd8a5d40af47e2e7 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_pwm.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_pwm.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_pwm.c  -o ${OBJECTDIR}/hal/hal_pwm.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_pwm.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_spi.o: hal/hal_spi.c  .generated_files/flags/default/bce7aa701a58944374b7f34a157c7dd02a65e7ab .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_spi.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_spi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_spi.c  -o ${OBJECTDIR}/hal/hal_spi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_spi.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_timer.o: hal/hal_timer.c  .generated_files/flags/default/8ca6cbbde0f16e48061dcbdbfc5ef88ec18c449a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_timer.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_timer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_timer.c  -o ${OBJECTDIR}/hal/hal_timer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_timer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_zcd.o: hal/hal_zcd.c  .generated_files/flags/default/50093b5eb2836a4f3007ea066f1bba185c084267 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_zcd.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_zcd.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_zcd.c  -o ${OBJECTDIR}/hal/hal_zcd.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_zcd.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/port_config.o: hal/port_config.c  .generated_files/flags/default/7ddf7237b6e7198d8fa39e2583c27a5c28a7b59d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/port_config.o.d 
	@${RM} ${OBJECTDIR}/hal/port_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/port_config.c  -o ${OBJECTDIR}/hal/port_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/port_config.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/timer1.o: hal/timer1.c  .generated_files/flags/default/4c8b01cfd3ce1d446be3f4d1be830ec87f67f67d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/timer1.o.d 
	@${RM} ${OBJECTDIR}/hal/timer1.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/timer1.c  -o ${OBJECTDIR}/hal/timer1.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/timer1.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/uart1.o: hal/uart1.c  .generated_files/flags/default/c0c6e9d631277334fe95765a0d7707b8e426ec37 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/uart1.o.d 
	@${RM} ${OBJECTDIR}/hal/uart1.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/uart1.c  -o ${OBJECTDIR}/hal/uart1.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/uart1.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/input/rx_decode.o: input/rx_decode.c  .generated_files/flags/default/d5f6115971c945ad536ed1ccd77166550d77ebcf .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/input" 
	@${RM} ${OBJECTDIR}/input/rx_decode.o.d 
	@${RM} ${OBJECTDIR}/input/rx_decode.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  input/rx_decode.c  -o ${OBJECTDIR}/input/rx_decode.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/input/rx_decode.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/adaptation.o: learn/adaptation.c  .generated_files/flags/default/fd29a342947687d327cf301ad0d6afe472b5c3c3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/adaptation.o.d 
	@${RM} ${OBJECTDIR}/learn/adaptation.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/adaptation.c  -o ${OBJECTDIR}/learn/adaptation.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/adaptation.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/commission.o: learn/commission.c  .generated_files/flags/default/e82643baeb97fe11d7b92125aca692f4816d75a2 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/commission.o.d 
	@${RM} ${OBJECTDIR}/learn/commission.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/commission.c  -o ${OBJECTDIR}/learn/commission.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/commission.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/health.o: learn/health.c  .generated_files/flags/default/5c405fba2aeaaaa271dc1d9d4e91b937a80146e9 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/health.o.d 
	@${RM} ${OBJECTDIR}/learn/health.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/health.c  -o ${OBJECTDIR}/learn/health.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/health.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/learn_service.o: learn/learn_service.c  .generated_files/flags/default/6a87b6f411e4d1291aa864c26d8ca0558d8683b5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/learn_service.o.d 
	@${RM} ${OBJECTDIR}/learn/learn_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/learn_service.c  -o ${OBJECTDIR}/learn/learn_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/learn_service.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/quality.o: learn/quality.c  .generated_files/flags/default/69f5581d45dc2fcab5d0319daec9dd639f495aa3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/quality.o.d 
	@${RM} ${OBJECTDIR}/learn/quality.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/quality.c  -o ${OBJECTDIR}/learn/quality.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/quality.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/ring_buffer.o: learn/ring_buffer.c  .generated_files/flags/default/68f9b32b0b4f65d817d73d467a814c0dda9ed891 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/ring_buffer.o.d 
	@${RM} ${OBJECTDIR}/learn/ring_buffer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/ring_buffer.c  -o ${OBJECTDIR}/learn/ring_buffer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/ring_buffer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/main.o: main.c  .generated_files/flags/default/cefa442bdc9cc7061d302230d8e9e71309f95a88 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main.o.d 
	@${RM} ${OBJECTDIR}/main.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  main.c  -o ${OBJECTDIR}/main.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/main.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/bemf_zc.o: motor/bemf_zc.c  .generated_files/flags/default/805ab6001d50401e7325f0196a6c9ab95f21fba7 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/bemf_zc.o.d 
	@${RM} ${OBJECTDIR}/motor/bemf_zc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/bemf_zc.c  -o ${OBJECTDIR}/motor/bemf_zc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/bemf_zc.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/commutation.o: motor/commutation.c  .generated_files/flags/default/638d0e136c9250429c252fda8ed8552238a6595b .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/commutation.o.d 
	@${RM} ${OBJECTDIR}/motor/commutation.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/commutation.c  -o ${OBJECTDIR}/motor/commutation.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/commutation.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/hwzc.o: motor/hwzc.c  .generated_files/flags/default/383760bb70e988d27ce4e478ceb740f261466d96 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/hwzc.o.d 
	@${RM} ${OBJECTDIR}/motor/hwzc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/hwzc.c  -o ${OBJECTDIR}/motor/hwzc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/hwzc.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/pi.o: motor/pi.c  .generated_files/flags/default/6ff193321444131626dc3a04807e53df396fe6f5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/pi.o.d 
	@${RM} ${OBJECTDIR}/motor/pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/pi.c  -o ${OBJECTDIR}/motor/pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/pi.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/speed_pi.o: motor/speed_pi.c  .generated_files/flags/default/57744606836732d686ee58b6219b2a3f46f163b2 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/speed_pi.o.d 
	@${RM} ${OBJECTDIR}/motor/speed_pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/speed_pi.c  -o ${OBJECTDIR}/motor/speed_pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/speed_pi.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/startup.o: motor/startup.c  .generated_files/flags/default/4daab2d00cb88c070c97bd3cb807c04d7545a370 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/startup.o.d 
	@${RM} ${OBJECTDIR}/motor/startup.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/startup.c  -o ${OBJECTDIR}/motor/startup.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/startup.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/scope/scope_burst.o: scope/scope_burst.c  .generated_files/flags/default/7aacc07c0d0f101b895f2eb9b1af9fab8ad5d262 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/scope" 
	@${RM} ${OBJECTDIR}/scope/scope_burst.o.d 
	@${RM} ${OBJECTDIR}/scope/scope_burst.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  scope/scope_burst.c  -o ${OBJECTDIR}/scope/scope_burst.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/scope/scope_burst.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/x2cscope/diagnostics.o: x2cscope/diagnostics.c  .generated_files/flags/default/4924ec9b958b0d146a34abdf9e8202ad1ed77f88 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/x2cscope" 
	@${RM} ${OBJECTDIR}/x2cscope/diagnostics.o.d 
	@${RM} ${OBJECTDIR}/x2cscope/diagnostics.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  x2cscope/diagnostics.c  -o ${OBJECTDIR}/x2cscope/diagnostics.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/x2cscope/diagnostics.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
else
${OBJECTDIR}/foc/an1078_motor.o: foc/an1078_motor.c  .generated_files/flags/default/188b9662bdab83fafef5a1e4371cb776a13a554d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/an1078_motor.o.d 
	@${RM} ${OBJECTDIR}/foc/an1078_motor.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_motor.c  -o ${OBJECTDIR}/foc/an1078_motor.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_motor.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/an1078_smc.o: foc/an1078_smc.c  .generated_files/flags/default/fbd243d1b482b655befb55f3043e70a40d979d0a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/an1078_smc.o.d 
	@${RM} ${OBJECTDIR}/foc/an1078_smc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_smc.c  -o ${OBJECTDIR}/foc/an1078_smc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_smc.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/back_emf_obs.o: foc/back_emf_obs.c  .generated_files/flags/default/2bbf942283a6bc7424771b8728497bd5c6c3bd4f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/back_emf_obs.o.d 
	@${RM} ${OBJECTDIR}/foc/back_emf_obs.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/back_emf_obs.c  -o ${OBJECTDIR}/foc/back_emf_obs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/back_emf_obs.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/clarke.o: foc/clarke.c  .generated_files/flags/default/ec17a3097bc36b195c37358be7dc276ecf345ac7 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/clarke.o.d 
	@${RM} ${OBJECTDIR}/foc/clarke.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/clarke.c  -o ${OBJECTDIR}/foc/clarke.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/clarke.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/flux_estimator.o: foc/flux_estimator.c  .generated_files/flags/default/f3ceb87b5f770794a4eb598e87a7bac8f029e0ba .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/flux_estimator.o.d 
	@${RM} ${OBJECTDIR}/foc/flux_estimator.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/flux_estimator.c  -o ${OBJECTDIR}/foc/flux_estimator.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/flux_estimator.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_control.o: foc/foc_v2_control.c  .generated_files/flags/default/c959f1e1f88d0b084b7e92c6aa851e251dd65fcf .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_control.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_control.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_control.c  -o ${OBJECTDIR}/foc/foc_v2_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_control.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_detect.o: foc/foc_v2_detect.c  .generated_files/flags/default/170f39c26aed60096d43a285b76fb0d25d022272 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_detect.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_detect.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_detect.c  -o ${OBJECTDIR}/foc/foc_v2_detect.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_detect.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_observer.o: foc/foc_v2_observer.c  .generated_files/flags/default/71b69532364d89ee1fd3a575d3a4b2cbbb64c7fb .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_observer.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_observer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_observer.c  -o ${OBJECTDIR}/foc/foc_v2_observer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_observer.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_pi.o: foc/foc_v2_pi.c  .generated_files/flags/default/ccd02ac6576672a3125209c5cdee0f8f5d6fcb32 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_pi.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_pi.c  -o ${OBJECTDIR}/foc/foc_v2_pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_pi.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v3_control.o: foc/foc_v3_control.c  .generated_files/flags/default/5f4ecb376311839a6156e5240917de0a1ebaa511 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v3_control.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v3_control.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v3_control.c  -o ${OBJECTDIR}/foc/foc_v3_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v3_control.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v3_smo.o: foc/foc_v3_smo.c  .generated_files/flags/default/72b02c58ed1c1b8823e9783757b32c6fa19a8ce .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v3_smo.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v3_smo.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v3_smo.c  -o ${OBJECTDIR}/foc/foc_v3_smo.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v3_smo.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/mxlemming_obs.o: foc/mxlemming_obs.c  .generated_files/flags/default/f49c23817cf482a79f212279de6fd32159dfad6f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/mxlemming_obs.o.d 
	@${RM} ${OBJECTDIR}/foc/mxlemming_obs.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/mxlemming_obs.c  -o ${OBJECTDIR}/foc/mxlemming_obs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/mxlemming_obs.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/park.o: foc/park.c  .generated_files/flags/default/6674a7c2e74bdcf3b1a266834618626ffb342aec .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/park.o.d 
	@${RM} ${OBJECTDIR}/foc/park.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/park.c  -o ${OBJECTDIR}/foc/park.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/park.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/pi_controller.o: foc/pi_controller.c  .generated_files/flags/default/97d1a01c43acdd873f5f6f3436094bb8cdd7c3ea .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/pi_controller.o.d 
	@${RM} ${OBJECTDIR}/foc/pi_controller.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/pi_controller.c  -o ${OBJECTDIR}/foc/pi_controller.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/pi_controller.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/pll_estimator.o: foc/pll_estimator.c  .generated_files/flags/default/6391588c21a6cd9947c1dd380bef8f5e05e9b60b .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/pll_estimator.o.d 
	@${RM} ${OBJECTDIR}/foc/pll_estimator.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/pll_estimator.c  -o ${OBJECTDIR}/foc/pll_estimator.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/pll_estimator.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/smo_observer.o: foc/smo_observer.c  .generated_files/flags/default/26683df98013f215223f471037dfb022d894fd13 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/smo_observer.o.d 
	@${RM} ${OBJECTDIR}/foc/smo_observer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/smo_observer.c  -o ${OBJECTDIR}/foc/smo_observer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/smo_observer.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/svpwm.o: foc/svpwm.c  .generated_files/flags/default/bd2d68c150883db357fb2eda911de83354759ba3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/svpwm.o.d 
	@${RM} ${OBJECTDIR}/foc/svpwm.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/svpwm.c  -o ${OBJECTDIR}/foc/svpwm.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/svpwm.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/garuda_service.o: garuda_service.c  .generated_files/flags/default/af42f0a448480e57cf3a26bafb15b3184af0562 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/garuda_service.o.d 
	@${RM} ${OBJECTDIR}/garuda_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  garuda_service.c  -o ${OBJECTDIR}/garuda_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/garuda_service.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp.o: gsp/gsp.c  .generated_files/flags/default/8fa068788a7db029fc942de62876cf9ea07c7505 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp.c  -o ${OBJECTDIR}/gsp/gsp.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_commands.o: gsp/gsp_commands.c  .generated_files/flags/default/505c3cb1f8cca9fb82f29bd468d7d69f9adf64b8 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_commands.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_commands.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_commands.c  -o ${OBJECTDIR}/gsp/gsp_commands.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_commands.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_params.o: gsp/gsp_params.c  .generated_files/flags/default/9879bcaf00cf3188d17a815c57a51c76e3617ad8 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_params.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_params.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_params.c  -o ${OBJECTDIR}/gsp/gsp_params.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_params.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_snapshot.o: gsp/gsp_snapshot.c  .generated_files/flags/default/539eb18320064f8f086cf6c57aeaf2d4d61bf136 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_snapshot.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_snapshot.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_snapshot.c  -o ${OBJECTDIR}/gsp/gsp_snapshot.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_snapshot.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/board_service.o: hal/board_service.c  .generated_files/flags/default/3769a963d5da50ec74e3108a516c3d6a6fb56caa .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/board_service.o.d 
	@${RM} ${OBJECTDIR}/hal/board_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/board_service.c  -o ${OBJECTDIR}/hal/board_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/board_service.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/clock.o: hal/clock.c  .generated_files/flags/default/725121fdca9998729b46eb88abffae7d17451dcd .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/clock.o.d 
	@${RM} ${OBJECTDIR}/hal/clock.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/clock.c  -o ${OBJECTDIR}/hal/clock.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/clock.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/device_config.o: hal/device_config.c  .generated_files/flags/default/4a43d742502319fc05704fa6799b24604595141f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/device_config.o.d 
	@${RM} ${OBJECTDIR}/hal/device_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/device_config.c  -o ${OBJECTDIR}/hal/device_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/device_config.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/eeprom.o: hal/eeprom.c  .generated_files/flags/default/d281739dbf6c739593055b55ceeedf4cb77840de .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/eeprom.o.d 
	@${RM} ${OBJECTDIR}/hal/eeprom.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/eeprom.c  -o ${OBJECTDIR}/hal/eeprom.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/eeprom.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_adc.o: hal/hal_adc.c  .generated_files/flags/default/e4b6eccd50b173615e40e38e4f6228a7bf237464 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_adc.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_adc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_adc.c  -o ${OBJECTDIR}/hal/hal_adc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_adc.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_ata6847.o: hal/hal_ata6847.c  .generated_files/flags/default/b80672101b4b6f64a9a6c70d427d24511e0abac5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_ata6847.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_ata6847.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_ata6847.c  -o ${OBJECTDIR}/hal/hal_ata6847.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_ata6847.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_input_capture.o: hal/hal_input_capture.c  .generated_files/flags/default/9f6ff776b9dba8f0a110a1179b12bd8516fb387e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_input_capture.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_input_capture.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_input_capture.c  -o ${OBJECTDIR}/hal/hal_input_capture.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_input_capture.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_pwm.o: hal/hal_pwm.c  .generated_files/flags/default/57cb69e552b8d3ab52158dff58893a74053afa82 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_pwm.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_pwm.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_pwm.c  -o ${OBJECTDIR}/hal/hal_pwm.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_pwm.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_spi.o: hal/hal_spi.c  .generated_files/flags/default/355d3bc80b77900e75538b6a65f90d93e781c1cc .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_spi.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_spi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_spi.c  -o ${OBJECTDIR}/hal/hal_spi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_spi.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_timer.o: hal/hal_timer.c  .generated_files/flags/default/bc114dc6b7a9b00a0b2ed7820a7e43ceb0e87ce0 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_timer.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_timer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_timer.c  -o ${OBJECTDIR}/hal/hal_timer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_timer.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_zcd.o: hal/hal_zcd.c  .generated_files/flags/default/f56e133978f99e1f90868f72f2f906abc5e26a81 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_zcd.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_zcd.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_zcd.c  -o ${OBJECTDIR}/hal/hal_zcd.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_zcd.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/port_config.o: hal/port_config.c  .generated_files/flags/default/ce419dbbe97bb56f3fbe2ef0ab4ba0fe1ebcedeb .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/port_config.o.d 
	@${RM} ${OBJECTDIR}/hal/port_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/port_config.c  -o ${OBJECTDIR}/hal/port_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/port_config.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/timer1.o: hal/timer1.c  .generated_files/flags/default/14bce7adeaf7fe9e917f18b22218ae3def92a957 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/timer1.o.d 
	@${RM} ${OBJECTDIR}/hal/timer1.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/timer1.c  -o ${OBJECTDIR}/hal/timer1.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/timer1.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/uart1.o: hal/uart1.c  .generated_files/flags/default/2c15c5024251974d78922ae45d5490a2fb9f85d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/uart1.o.d 
	@${RM} ${OBJECTDIR}/hal/uart1.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/uart1.c  -o ${OBJECTDIR}/hal/uart1.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/uart1.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/input/rx_decode.o: input/rx_decode.c  .generated_files/flags/default/c4772a469d9e138c7e32d1965cd061856ae4852b .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/input" 
	@${RM} ${OBJECTDIR}/input/rx_decode.o.d 
	@${RM} ${OBJECTDIR}/input/rx_decode.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  input/rx_decode.c  -o ${OBJECTDIR}/input/rx_decode.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/input/rx_decode.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/adaptation.o: learn/adaptation.c  .generated_files/flags/default/44c7f04f6ffae9f18dae7fea696dae3311ad2a71 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/adaptation.o.d 
	@${RM} ${OBJECTDIR}/learn/adaptation.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/adaptation.c  -o ${OBJECTDIR}/learn/adaptation.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/adaptation.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/commission.o: learn/commission.c  .generated_files/flags/default/a29de6be6f05a1ac94517f1555b7f9ca1cb7f3f0 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/commission.o.d 
	@${RM} ${OBJECTDIR}/learn/commission.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/commission.c  -o ${OBJECTDIR}/learn/commission.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/commission.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/health.o: learn/health.c  .generated_files/flags/default/6e4622cd6587b6c9bb7f0cbae9ef8b34745999b0 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/health.o.d 
	@${RM} ${OBJECTDIR}/learn/health.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/health.c  -o ${OBJECTDIR}/learn/health.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/health.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/learn_service.o: learn/learn_service.c  .generated_files/flags/default/b8d986fb1d93b4c18cb200ed759bebf7106c0f1c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/learn_service.o.d 
	@${RM} ${OBJECTDIR}/learn/learn_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/learn_service.c  -o ${OBJECTDIR}/learn/learn_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/learn_service.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/quality.o: learn/quality.c  .generated_files/flags/default/2ddfc60bc1e875aa5abf9c80eac875a561982414 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/quality.o.d 
	@${RM} ${OBJECTDIR}/learn/quality.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/quality.c  -o ${OBJECTDIR}/learn/quality.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/quality.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/ring_buffer.o: learn/ring_buffer.c  .generated_files/flags/default/f47181214d67ab4595c55e6aadb0fb49c4bb7181 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/ring_buffer.o.d 
	@${RM} ${OBJECTDIR}/learn/ring_buffer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/ring_buffer.c  -o ${OBJECTDIR}/learn/ring_buffer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/ring_buffer.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/main.o: main.c  .generated_files/flags/default/57be8accc035cab656993f29131b93c6d7f24b5b .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main.o.d 
	@${RM} ${OBJECTDIR}/main.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  main.c  -o ${OBJECTDIR}/main.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/main.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/bemf_zc.o: motor/bemf_zc.c  .generated_files/flags/default/57272864435edcb10517defe00124b48be97f3a2 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/bemf_zc.o.d 
	@${RM} ${OBJECTDIR}/motor/bemf_zc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/bemf_zc.c  -o ${OBJECTDIR}/motor/bemf_zc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/bemf_zc.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/commutation.o: motor/commutation.c  .generated_files/flags/default/e66ba422efaa5e53b8bd25af442276d86341a31b .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/commutation.o.d 
	@${RM} ${OBJECTDIR}/motor/commutation.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/commutation.c  -o ${OBJECTDIR}/motor/commutation.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/commutation.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/hwzc.o: motor/hwzc.c  .generated_files/flags/default/919f9348f562d44bca5af992d28db1392d275fc4 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/hwzc.o.d 
	@${RM} ${OBJECTDIR}/motor/hwzc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/hwzc.c  -o ${OBJECTDIR}/motor/hwzc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/hwzc.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/pi.o: motor/pi.c  .generated_files/flags/default/d4ad949c4df7a39085144b7c94c791f087332744 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/pi.o.d 
	@${RM} ${OBJECTDIR}/motor/pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/pi.c  -o ${OBJECTDIR}/motor/pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/pi.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/speed_pi.o: motor/speed_pi.c  .generated_files/flags/default/c60f41cde610a1b3bccc8a0e0eef0115b15d8899 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/speed_pi.o.d 
	@${RM} ${OBJECTDIR}/motor/speed_pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/speed_pi.c  -o ${OBJECTDIR}/motor/speed_pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/speed_pi.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/startup.o: motor/startup.c  .generated_files/flags/default/a045104a106e1e1f47d9376fd92c0acb8e079c09 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/startup.o.d 
	@${RM} ${OBJECTDIR}/motor/startup.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/startup.c  -o ${OBJECTDIR}/motor/startup.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/startup.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/scope/scope_burst.o: scope/scope_burst.c  .generated_files/flags/default/461882eab5f676acdd64ac17ec8612df69f5853d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/scope" 
	@${RM} ${OBJECTDIR}/scope/scope_burst.o.d 
	@${RM} ${OBJECTDIR}/scope/scope_burst.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  scope/scope_burst.c  -o ${OBJECTDIR}/scope/scope_burst.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/scope/scope_burst.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/x2cscope/diagnostics.o: x2cscope/diagnostics.c  .generated_files/flags/default/6300a5a41f2c71ee8970778d644be4c660b1f662 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/x2cscope" 
	@${RM} ${OBJECTDIR}/x2cscope/diagnostics.o.d 
	@${RM} ${OBJECTDIR}/x2cscope/diagnostics.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  x2cscope/diagnostics.c  -o ${OBJECTDIR}/x2cscope/diagnostics.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/x2cscope/diagnostics.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemblePreproc
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${DISTDIR}/garuda_ese.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o ${DISTDIR}/garuda_ese.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}      -mcpu=$(MP_PROCESSOR_OPTION)        -D__DEBUG=__DEBUG -D__MPLAB_DEBUGGER_PK5=1  -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)      -Wl,,,--defsym=__MPLAB_BUILD=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,-D__DEBUG=__DEBUG,--defsym=__MPLAB_DEBUGGER_PK5=1,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--no-gc-sections,--fill-upper=0,--stackguard=16,--ivt,--isr,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem,--memorysummary,${DISTDIR}/memoryfile.xml$(MP_EXTRA_LD_POST)  -mdfp="${DFP_DIR}/xc16" 
	
else
${DISTDIR}/garuda_ese.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o ${DISTDIR}/garuda_ese.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}      -mcpu=$(MP_PROCESSOR_OPTION)        -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wl,,,--defsym=__MPLAB_BUILD=1,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--no-gc-sections,--fill-upper=0,--stackguard=16,--ivt,--isr,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem,--memorysummary,${DISTDIR}/memoryfile.xml$(MP_EXTRA_LD_POST)  -mdfp="${DFP_DIR}/xc16" 
	${MP_CC_DIR}/xc-dsc-bin2hex ${DISTDIR}/garuda_ese.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX} -a  -omf=elf   -mdfp="${DFP_DIR}/xc16" 
	
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r ${OBJECTDIR}
	${RM} -r ${DISTDIR}

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(wildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
