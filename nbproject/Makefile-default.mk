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
FINAL_IMAGE=${DISTDIR}/garuda-ese-pristine.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/garuda-ese-pristine.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
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
SOURCEFILES_QUOTED_IF_SPACED=foc/an1078_motor.c foc/an1078_smc.c foc/an1078_sta.c foc/back_emf_obs.c foc/clarke.c foc/flux_estimator.c foc/foc_v2_control.c foc/foc_v2_detect.c foc/foc_v2_observer.c foc/foc_v2_pi.c foc/foc_v3_control.c foc/foc_v3_smo.c foc/mxlemming_obs.c foc/park.c foc/pi_controller.c foc/pll_estimator.c foc/smo_observer.c foc/svpwm.c garuda_service.c gsp/gsp.c gsp/gsp_commands.c gsp/gsp_params.c gsp/gsp_snapshot.c hal/board_service.c hal/clock.c hal/device_config.c hal/eeprom.c hal/hal_adc.c hal/hal_ata6847.c hal/hal_input_capture.c hal/hal_pwm.c hal/hal_spi.c hal/hal_timer.c hal/hal_zcd.c hal/port_config.c hal/timer1.c hal/uart1.c input/rx_decode.c learn/adaptation.c learn/commission.c learn/health.c learn/learn_service.c learn/quality.c learn/ring_buffer.c main.c motor/bemf_zc.c motor/commutation.c motor/hwzc.c motor/pi.c motor/speed_pi.c motor/startup.c scope/scope_burst.c x2cscope/diagnostics.c

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/foc/an1078_motor.o ${OBJECTDIR}/foc/an1078_smc.o ${OBJECTDIR}/foc/an1078_sta.o ${OBJECTDIR}/foc/back_emf_obs.o ${OBJECTDIR}/foc/clarke.o ${OBJECTDIR}/foc/flux_estimator.o ${OBJECTDIR}/foc/foc_v2_control.o ${OBJECTDIR}/foc/foc_v2_detect.o ${OBJECTDIR}/foc/foc_v2_observer.o ${OBJECTDIR}/foc/foc_v2_pi.o ${OBJECTDIR}/foc/foc_v3_control.o ${OBJECTDIR}/foc/foc_v3_smo.o ${OBJECTDIR}/foc/mxlemming_obs.o ${OBJECTDIR}/foc/park.o ${OBJECTDIR}/foc/pi_controller.o ${OBJECTDIR}/foc/pll_estimator.o ${OBJECTDIR}/foc/smo_observer.o ${OBJECTDIR}/foc/svpwm.o ${OBJECTDIR}/garuda_service.o ${OBJECTDIR}/gsp/gsp.o ${OBJECTDIR}/gsp/gsp_commands.o ${OBJECTDIR}/gsp/gsp_params.o ${OBJECTDIR}/gsp/gsp_snapshot.o ${OBJECTDIR}/hal/board_service.o ${OBJECTDIR}/hal/clock.o ${OBJECTDIR}/hal/device_config.o ${OBJECTDIR}/hal/eeprom.o ${OBJECTDIR}/hal/hal_adc.o ${OBJECTDIR}/hal/hal_ata6847.o ${OBJECTDIR}/hal/hal_input_capture.o ${OBJECTDIR}/hal/hal_pwm.o ${OBJECTDIR}/hal/hal_spi.o ${OBJECTDIR}/hal/hal_timer.o ${OBJECTDIR}/hal/hal_zcd.o ${OBJECTDIR}/hal/port_config.o ${OBJECTDIR}/hal/timer1.o ${OBJECTDIR}/hal/uart1.o ${OBJECTDIR}/input/rx_decode.o ${OBJECTDIR}/learn/adaptation.o ${OBJECTDIR}/learn/commission.o ${OBJECTDIR}/learn/health.o ${OBJECTDIR}/learn/learn_service.o ${OBJECTDIR}/learn/quality.o ${OBJECTDIR}/learn/ring_buffer.o ${OBJECTDIR}/main.o ${OBJECTDIR}/motor/bemf_zc.o ${OBJECTDIR}/motor/commutation.o ${OBJECTDIR}/motor/hwzc.o ${OBJECTDIR}/motor/pi.o ${OBJECTDIR}/motor/speed_pi.o ${OBJECTDIR}/motor/startup.o ${OBJECTDIR}/scope/scope_burst.o ${OBJECTDIR}/x2cscope/diagnostics.o
POSSIBLE_DEPFILES=${OBJECTDIR}/foc/an1078_motor.o.d ${OBJECTDIR}/foc/an1078_smc.o.d ${OBJECTDIR}/foc/an1078_sta.o.d ${OBJECTDIR}/foc/back_emf_obs.o.d ${OBJECTDIR}/foc/clarke.o.d ${OBJECTDIR}/foc/flux_estimator.o.d ${OBJECTDIR}/foc/foc_v2_control.o.d ${OBJECTDIR}/foc/foc_v2_detect.o.d ${OBJECTDIR}/foc/foc_v2_observer.o.d ${OBJECTDIR}/foc/foc_v2_pi.o.d ${OBJECTDIR}/foc/foc_v3_control.o.d ${OBJECTDIR}/foc/foc_v3_smo.o.d ${OBJECTDIR}/foc/mxlemming_obs.o.d ${OBJECTDIR}/foc/park.o.d ${OBJECTDIR}/foc/pi_controller.o.d ${OBJECTDIR}/foc/pll_estimator.o.d ${OBJECTDIR}/foc/smo_observer.o.d ${OBJECTDIR}/foc/svpwm.o.d ${OBJECTDIR}/garuda_service.o.d ${OBJECTDIR}/gsp/gsp.o.d ${OBJECTDIR}/gsp/gsp_commands.o.d ${OBJECTDIR}/gsp/gsp_params.o.d ${OBJECTDIR}/gsp/gsp_snapshot.o.d ${OBJECTDIR}/hal/board_service.o.d ${OBJECTDIR}/hal/clock.o.d ${OBJECTDIR}/hal/device_config.o.d ${OBJECTDIR}/hal/eeprom.o.d ${OBJECTDIR}/hal/hal_adc.o.d ${OBJECTDIR}/hal/hal_ata6847.o.d ${OBJECTDIR}/hal/hal_input_capture.o.d ${OBJECTDIR}/hal/hal_pwm.o.d ${OBJECTDIR}/hal/hal_spi.o.d ${OBJECTDIR}/hal/hal_timer.o.d ${OBJECTDIR}/hal/hal_zcd.o.d ${OBJECTDIR}/hal/port_config.o.d ${OBJECTDIR}/hal/timer1.o.d ${OBJECTDIR}/hal/uart1.o.d ${OBJECTDIR}/input/rx_decode.o.d ${OBJECTDIR}/learn/adaptation.o.d ${OBJECTDIR}/learn/commission.o.d ${OBJECTDIR}/learn/health.o.d ${OBJECTDIR}/learn/learn_service.o.d ${OBJECTDIR}/learn/quality.o.d ${OBJECTDIR}/learn/ring_buffer.o.d ${OBJECTDIR}/main.o.d ${OBJECTDIR}/motor/bemf_zc.o.d ${OBJECTDIR}/motor/commutation.o.d ${OBJECTDIR}/motor/hwzc.o.d ${OBJECTDIR}/motor/pi.o.d ${OBJECTDIR}/motor/speed_pi.o.d ${OBJECTDIR}/motor/startup.o.d ${OBJECTDIR}/scope/scope_burst.o.d ${OBJECTDIR}/x2cscope/diagnostics.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/foc/an1078_motor.o ${OBJECTDIR}/foc/an1078_smc.o ${OBJECTDIR}/foc/an1078_sta.o ${OBJECTDIR}/foc/back_emf_obs.o ${OBJECTDIR}/foc/clarke.o ${OBJECTDIR}/foc/flux_estimator.o ${OBJECTDIR}/foc/foc_v2_control.o ${OBJECTDIR}/foc/foc_v2_detect.o ${OBJECTDIR}/foc/foc_v2_observer.o ${OBJECTDIR}/foc/foc_v2_pi.o ${OBJECTDIR}/foc/foc_v3_control.o ${OBJECTDIR}/foc/foc_v3_smo.o ${OBJECTDIR}/foc/mxlemming_obs.o ${OBJECTDIR}/foc/park.o ${OBJECTDIR}/foc/pi_controller.o ${OBJECTDIR}/foc/pll_estimator.o ${OBJECTDIR}/foc/smo_observer.o ${OBJECTDIR}/foc/svpwm.o ${OBJECTDIR}/garuda_service.o ${OBJECTDIR}/gsp/gsp.o ${OBJECTDIR}/gsp/gsp_commands.o ${OBJECTDIR}/gsp/gsp_params.o ${OBJECTDIR}/gsp/gsp_snapshot.o ${OBJECTDIR}/hal/board_service.o ${OBJECTDIR}/hal/clock.o ${OBJECTDIR}/hal/device_config.o ${OBJECTDIR}/hal/eeprom.o ${OBJECTDIR}/hal/hal_adc.o ${OBJECTDIR}/hal/hal_ata6847.o ${OBJECTDIR}/hal/hal_input_capture.o ${OBJECTDIR}/hal/hal_pwm.o ${OBJECTDIR}/hal/hal_spi.o ${OBJECTDIR}/hal/hal_timer.o ${OBJECTDIR}/hal/hal_zcd.o ${OBJECTDIR}/hal/port_config.o ${OBJECTDIR}/hal/timer1.o ${OBJECTDIR}/hal/uart1.o ${OBJECTDIR}/input/rx_decode.o ${OBJECTDIR}/learn/adaptation.o ${OBJECTDIR}/learn/commission.o ${OBJECTDIR}/learn/health.o ${OBJECTDIR}/learn/learn_service.o ${OBJECTDIR}/learn/quality.o ${OBJECTDIR}/learn/ring_buffer.o ${OBJECTDIR}/main.o ${OBJECTDIR}/motor/bemf_zc.o ${OBJECTDIR}/motor/commutation.o ${OBJECTDIR}/motor/hwzc.o ${OBJECTDIR}/motor/pi.o ${OBJECTDIR}/motor/speed_pi.o ${OBJECTDIR}/motor/startup.o ${OBJECTDIR}/scope/scope_burst.o ${OBJECTDIR}/x2cscope/diagnostics.o

# Source Files
SOURCEFILES=foc/an1078_motor.c foc/an1078_smc.c foc/an1078_sta.c foc/back_emf_obs.c foc/clarke.c foc/flux_estimator.c foc/foc_v2_control.c foc/foc_v2_detect.c foc/foc_v2_observer.c foc/foc_v2_pi.c foc/foc_v3_control.c foc/foc_v3_smo.c foc/mxlemming_obs.c foc/park.c foc/pi_controller.c foc/pll_estimator.c foc/smo_observer.c foc/svpwm.c garuda_service.c gsp/gsp.c gsp/gsp_commands.c gsp/gsp_params.c gsp/gsp_snapshot.c hal/board_service.c hal/clock.c hal/device_config.c hal/eeprom.c hal/hal_adc.c hal/hal_ata6847.c hal/hal_input_capture.c hal/hal_pwm.c hal/hal_spi.c hal/hal_timer.c hal/hal_zcd.c hal/port_config.c hal/timer1.c hal/uart1.c input/rx_decode.c learn/adaptation.c learn/commission.c learn/health.c learn/learn_service.c learn/quality.c learn/ring_buffer.c main.c motor/bemf_zc.c motor/commutation.c motor/hwzc.c motor/pi.c motor/speed_pi.c motor/startup.c scope/scope_burst.c x2cscope/diagnostics.c



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
	${MAKE}  -f nbproject/Makefile-default.mk ${DISTDIR}/garuda-ese-pristine.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=33AK256MC506
MP_LINKER_FILE_OPTION=,--script=p33AK256MC506.gld
# ------------------------------------------------------------------------------------
# Rules for buildStep: compile
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/foc/an1078_motor.o: foc/an1078_motor.c  .generated_files/flags/default/b5c5125337c754ed4c3895ee4ba40241b300e525 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/an1078_motor.o.d 
	@${RM} ${OBJECTDIR}/foc/an1078_motor.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_motor.c  -o ${OBJECTDIR}/foc/an1078_motor.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_motor.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/an1078_smc.o: foc/an1078_smc.c  .generated_files/flags/default/a10611f19e89db7b69a95c7ec055e7a50591ab3e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc"
	@${RM} ${OBJECTDIR}/foc/an1078_smc.o.d
	@${RM} ${OBJECTDIR}/foc/an1078_smc.o
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_smc.c  -o ${OBJECTDIR}/foc/an1078_smc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_smc.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"

${OBJECTDIR}/foc/an1078_sta.o: foc/an1078_sta.c  .generated_files/flags/default/a65cf68f928b20779c5f2d1405c6c2fb1043067e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc"
	@${RM} ${OBJECTDIR}/foc/an1078_sta.o.d
	@${RM} ${OBJECTDIR}/foc/an1078_sta.o
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_sta.c  -o ${OBJECTDIR}/foc/an1078_sta.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_sta.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"

${OBJECTDIR}/foc/back_emf_obs.o: foc/back_emf_obs.c  .generated_files/flags/default/a2ca5321317c956d27e6282da647c4208e1ee3c9 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/back_emf_obs.o.d 
	@${RM} ${OBJECTDIR}/foc/back_emf_obs.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/back_emf_obs.c  -o ${OBJECTDIR}/foc/back_emf_obs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/back_emf_obs.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/clarke.o: foc/clarke.c  .generated_files/flags/default/bb75817a1d1b1655d8ddc6229d8927fd9d98b399 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/clarke.o.d 
	@${RM} ${OBJECTDIR}/foc/clarke.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/clarke.c  -o ${OBJECTDIR}/foc/clarke.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/clarke.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/flux_estimator.o: foc/flux_estimator.c  .generated_files/flags/default/31b09ba5aa8282ace50a3772c895b9a5c55de116 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/flux_estimator.o.d 
	@${RM} ${OBJECTDIR}/foc/flux_estimator.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/flux_estimator.c  -o ${OBJECTDIR}/foc/flux_estimator.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/flux_estimator.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_control.o: foc/foc_v2_control.c  .generated_files/flags/default/35c02b89b2933d31d74b1df6d05eb4fb9c67f7c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_control.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_control.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_control.c  -o ${OBJECTDIR}/foc/foc_v2_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_control.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_detect.o: foc/foc_v2_detect.c  .generated_files/flags/default/706f2470ea7ab049a991e165588aef41345beb7a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_detect.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_detect.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_detect.c  -o ${OBJECTDIR}/foc/foc_v2_detect.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_detect.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_observer.o: foc/foc_v2_observer.c  .generated_files/flags/default/45bf7b6454a2cc437f67295a6a0928946cb1b555 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_observer.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_observer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_observer.c  -o ${OBJECTDIR}/foc/foc_v2_observer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_observer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_pi.o: foc/foc_v2_pi.c  .generated_files/flags/default/a9f80f8b015e2cfec8cfb39f8536d0f83bf18e3e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_pi.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_pi.c  -o ${OBJECTDIR}/foc/foc_v2_pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_pi.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v3_control.o: foc/foc_v3_control.c  .generated_files/flags/default/35446ae6e10909edffaa9651e64306e5418e7d98 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v3_control.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v3_control.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v3_control.c  -o ${OBJECTDIR}/foc/foc_v3_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v3_control.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v3_smo.o: foc/foc_v3_smo.c  .generated_files/flags/default/fb23fe94fd6ad78d8938fd5931e6edb585115b7b .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v3_smo.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v3_smo.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v3_smo.c  -o ${OBJECTDIR}/foc/foc_v3_smo.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v3_smo.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/mxlemming_obs.o: foc/mxlemming_obs.c  .generated_files/flags/default/84b66ffc7c0980f4f13e6c6a4482870a0f933637 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/mxlemming_obs.o.d 
	@${RM} ${OBJECTDIR}/foc/mxlemming_obs.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/mxlemming_obs.c  -o ${OBJECTDIR}/foc/mxlemming_obs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/mxlemming_obs.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/park.o: foc/park.c  .generated_files/flags/default/b4af9f1b7f648f514c38187ca9e3170179ddd9ba .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/park.o.d 
	@${RM} ${OBJECTDIR}/foc/park.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/park.c  -o ${OBJECTDIR}/foc/park.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/park.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/pi_controller.o: foc/pi_controller.c  .generated_files/flags/default/6b03345d4329fdf0d596ca294933d42cbee182a8 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/pi_controller.o.d 
	@${RM} ${OBJECTDIR}/foc/pi_controller.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/pi_controller.c  -o ${OBJECTDIR}/foc/pi_controller.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/pi_controller.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/pll_estimator.o: foc/pll_estimator.c  .generated_files/flags/default/ce0463df52d24a9237927b949bea5bb4e2fb3f4a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/pll_estimator.o.d 
	@${RM} ${OBJECTDIR}/foc/pll_estimator.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/pll_estimator.c  -o ${OBJECTDIR}/foc/pll_estimator.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/pll_estimator.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/smo_observer.o: foc/smo_observer.c  .generated_files/flags/default/2dc65175789ffc6fe617cd4476f1f7a4d14320 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/smo_observer.o.d 
	@${RM} ${OBJECTDIR}/foc/smo_observer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/smo_observer.c  -o ${OBJECTDIR}/foc/smo_observer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/smo_observer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/svpwm.o: foc/svpwm.c  .generated_files/flags/default/903e376a4083c505b545ecafb58acfdad0b4a0ef .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/svpwm.o.d 
	@${RM} ${OBJECTDIR}/foc/svpwm.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/svpwm.c  -o ${OBJECTDIR}/foc/svpwm.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/svpwm.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/garuda_service.o: garuda_service.c  .generated_files/flags/default/e3a3a610573d8d45ee989b20fd2a61902a4912b4 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/garuda_service.o.d 
	@${RM} ${OBJECTDIR}/garuda_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  garuda_service.c  -o ${OBJECTDIR}/garuda_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/garuda_service.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp.o: gsp/gsp.c  .generated_files/flags/default/2a56caf63ba3dbd8feaadce54bbbab4c7406b64 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp.c  -o ${OBJECTDIR}/gsp/gsp.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_commands.o: gsp/gsp_commands.c  .generated_files/flags/default/f4f23f42d6fadc1e063e90efae0d34c87eb38c5f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_commands.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_commands.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_commands.c  -o ${OBJECTDIR}/gsp/gsp_commands.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_commands.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_params.o: gsp/gsp_params.c  .generated_files/flags/default/c748d87515e23033f985fb8bdeae85221cae74ff .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_params.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_params.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_params.c  -o ${OBJECTDIR}/gsp/gsp_params.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_params.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_snapshot.o: gsp/gsp_snapshot.c  .generated_files/flags/default/4e4add4aa8b4c03f9d20b1858ea7b1665178cb7a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_snapshot.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_snapshot.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_snapshot.c  -o ${OBJECTDIR}/gsp/gsp_snapshot.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_snapshot.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/board_service.o: hal/board_service.c  .generated_files/flags/default/d6859be93c4a6874d36968c6292ef10939869454 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/board_service.o.d 
	@${RM} ${OBJECTDIR}/hal/board_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/board_service.c  -o ${OBJECTDIR}/hal/board_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/board_service.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/clock.o: hal/clock.c  .generated_files/flags/default/e80ffeb727c15dc34badd8d419a747bb16c30943 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/clock.o.d 
	@${RM} ${OBJECTDIR}/hal/clock.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/clock.c  -o ${OBJECTDIR}/hal/clock.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/clock.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/device_config.o: hal/device_config.c  .generated_files/flags/default/cc56f48144cbd85fa133728456c820bee2c3018a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/device_config.o.d 
	@${RM} ${OBJECTDIR}/hal/device_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/device_config.c  -o ${OBJECTDIR}/hal/device_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/device_config.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/eeprom.o: hal/eeprom.c  .generated_files/flags/default/b8b914a295ec739455434b87d227cfcd80f557fc .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/eeprom.o.d 
	@${RM} ${OBJECTDIR}/hal/eeprom.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/eeprom.c  -o ${OBJECTDIR}/hal/eeprom.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/eeprom.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_adc.o: hal/hal_adc.c  .generated_files/flags/default/68ec7516e62b2b4da9a6dfa7f4be2608e50f5ff .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_adc.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_adc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_adc.c  -o ${OBJECTDIR}/hal/hal_adc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_adc.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_ata6847.o: hal/hal_ata6847.c  .generated_files/flags/default/87442f96e79db33e41c26ba7479711a72d656c74 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_ata6847.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_ata6847.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_ata6847.c  -o ${OBJECTDIR}/hal/hal_ata6847.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_ata6847.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_input_capture.o: hal/hal_input_capture.c  .generated_files/flags/default/99b82bace21a82d0c9222a4c703d23d856bdab35 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_input_capture.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_input_capture.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_input_capture.c  -o ${OBJECTDIR}/hal/hal_input_capture.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_input_capture.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_pwm.o: hal/hal_pwm.c  .generated_files/flags/default/8f5ff4014d4e4bb03b15cbdeb6a2c6a003e336a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_pwm.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_pwm.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_pwm.c  -o ${OBJECTDIR}/hal/hal_pwm.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_pwm.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_spi.o: hal/hal_spi.c  .generated_files/flags/default/13d2de565067cef321e8782248982b068ec2b198 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_spi.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_spi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_spi.c  -o ${OBJECTDIR}/hal/hal_spi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_spi.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_timer.o: hal/hal_timer.c  .generated_files/flags/default/7b349ebe9f5fe3112b280c770682ab6e69c40af3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_timer.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_timer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_timer.c  -o ${OBJECTDIR}/hal/hal_timer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_timer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_zcd.o: hal/hal_zcd.c  .generated_files/flags/default/79a11b634c8defec838b45241018ec1ef0f1ed14 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_zcd.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_zcd.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_zcd.c  -o ${OBJECTDIR}/hal/hal_zcd.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_zcd.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/port_config.o: hal/port_config.c  .generated_files/flags/default/42dcb1b3b98c3b96ff061bc42d998ec3086ca1ae .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/port_config.o.d 
	@${RM} ${OBJECTDIR}/hal/port_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/port_config.c  -o ${OBJECTDIR}/hal/port_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/port_config.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/timer1.o: hal/timer1.c  .generated_files/flags/default/6c37bfdb9e3fda0e2e143b3b751a749a6ce47eb .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/timer1.o.d 
	@${RM} ${OBJECTDIR}/hal/timer1.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/timer1.c  -o ${OBJECTDIR}/hal/timer1.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/timer1.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/uart1.o: hal/uart1.c  .generated_files/flags/default/68289badd3511ab83f319a3c5173d9c893a9c5da .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/uart1.o.d 
	@${RM} ${OBJECTDIR}/hal/uart1.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/uart1.c  -o ${OBJECTDIR}/hal/uart1.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/uart1.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/input/rx_decode.o: input/rx_decode.c  .generated_files/flags/default/6061aa68ccd64145619fda7105d7570822dfa3c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/input" 
	@${RM} ${OBJECTDIR}/input/rx_decode.o.d 
	@${RM} ${OBJECTDIR}/input/rx_decode.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  input/rx_decode.c  -o ${OBJECTDIR}/input/rx_decode.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/input/rx_decode.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/adaptation.o: learn/adaptation.c  .generated_files/flags/default/d72c4a0f969a21a034ba46d451a3554abef1d235 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/adaptation.o.d 
	@${RM} ${OBJECTDIR}/learn/adaptation.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/adaptation.c  -o ${OBJECTDIR}/learn/adaptation.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/adaptation.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/commission.o: learn/commission.c  .generated_files/flags/default/5efef93e672b9b6213b34800923bf314f5d72a38 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/commission.o.d 
	@${RM} ${OBJECTDIR}/learn/commission.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/commission.c  -o ${OBJECTDIR}/learn/commission.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/commission.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/health.o: learn/health.c  .generated_files/flags/default/c2c77f9424c580cfdb117bb216c38bc174c08607 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/health.o.d 
	@${RM} ${OBJECTDIR}/learn/health.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/health.c  -o ${OBJECTDIR}/learn/health.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/health.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/learn_service.o: learn/learn_service.c  .generated_files/flags/default/b7101ce26c20acbdd8a82a5b9be7121a05dd6057 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/learn_service.o.d 
	@${RM} ${OBJECTDIR}/learn/learn_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/learn_service.c  -o ${OBJECTDIR}/learn/learn_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/learn_service.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/quality.o: learn/quality.c  .generated_files/flags/default/225e7f217dc571c00a6a5c0a681c7c72bc450d94 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/quality.o.d 
	@${RM} ${OBJECTDIR}/learn/quality.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/quality.c  -o ${OBJECTDIR}/learn/quality.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/quality.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/ring_buffer.o: learn/ring_buffer.c  .generated_files/flags/default/dc392da070e8c9a7003c3b8f2ebb77cda166061f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/ring_buffer.o.d 
	@${RM} ${OBJECTDIR}/learn/ring_buffer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/ring_buffer.c  -o ${OBJECTDIR}/learn/ring_buffer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/ring_buffer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/main.o: main.c  .generated_files/flags/default/d3a5710ac658623f9ac302f6bb6b0702fe3257e1 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main.o.d 
	@${RM} ${OBJECTDIR}/main.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  main.c  -o ${OBJECTDIR}/main.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/main.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/bemf_zc.o: motor/bemf_zc.c  .generated_files/flags/default/19260369bddc57ed15bc9d641aed04994acc214d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/bemf_zc.o.d 
	@${RM} ${OBJECTDIR}/motor/bemf_zc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/bemf_zc.c  -o ${OBJECTDIR}/motor/bemf_zc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/bemf_zc.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/commutation.o: motor/commutation.c  .generated_files/flags/default/2ebad21df0cc6fcada163c38f4156ad5f3f2fec4 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/commutation.o.d 
	@${RM} ${OBJECTDIR}/motor/commutation.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/commutation.c  -o ${OBJECTDIR}/motor/commutation.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/commutation.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/hwzc.o: motor/hwzc.c  .generated_files/flags/default/b6879d81c761bd45f0ca9eaf63f972766917c060 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/hwzc.o.d 
	@${RM} ${OBJECTDIR}/motor/hwzc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/hwzc.c  -o ${OBJECTDIR}/motor/hwzc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/hwzc.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/pi.o: motor/pi.c  .generated_files/flags/default/fa1ca1007166690e65371a85617aac16e257aeb5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/pi.o.d 
	@${RM} ${OBJECTDIR}/motor/pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/pi.c  -o ${OBJECTDIR}/motor/pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/pi.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/speed_pi.o: motor/speed_pi.c  .generated_files/flags/default/1bbf35a8082538d9b44b9e107b5da9727cd63643 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/speed_pi.o.d 
	@${RM} ${OBJECTDIR}/motor/speed_pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/speed_pi.c  -o ${OBJECTDIR}/motor/speed_pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/speed_pi.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/startup.o: motor/startup.c  .generated_files/flags/default/6a6e23c181a1acf9e407c11b7bce44501f8c46fe .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/startup.o.d 
	@${RM} ${OBJECTDIR}/motor/startup.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/startup.c  -o ${OBJECTDIR}/motor/startup.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/startup.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/scope/scope_burst.o: scope/scope_burst.c  .generated_files/flags/default/22b29a1d88d5c8c9298ad6cc4af46b8eb869a75 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/scope" 
	@${RM} ${OBJECTDIR}/scope/scope_burst.o.d 
	@${RM} ${OBJECTDIR}/scope/scope_burst.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  scope/scope_burst.c  -o ${OBJECTDIR}/scope/scope_burst.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/scope/scope_burst.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/x2cscope/diagnostics.o: x2cscope/diagnostics.c  .generated_files/flags/default/76aac5ca97ead66359f087c0ff03e1fdbce1f9b4 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/x2cscope" 
	@${RM} ${OBJECTDIR}/x2cscope/diagnostics.o.d 
	@${RM} ${OBJECTDIR}/x2cscope/diagnostics.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  x2cscope/diagnostics.c  -o ${OBJECTDIR}/x2cscope/diagnostics.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/x2cscope/diagnostics.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK5=1    -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
else
${OBJECTDIR}/foc/an1078_motor.o: foc/an1078_motor.c  .generated_files/flags/default/e45b23b498dc3f54bc4b3c30e0bca6665c0b1f85 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/an1078_motor.o.d 
	@${RM} ${OBJECTDIR}/foc/an1078_motor.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_motor.c  -o ${OBJECTDIR}/foc/an1078_motor.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_motor.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/an1078_smc.o: foc/an1078_smc.c  .generated_files/flags/default/e07dee1f656615e5d99d3335919bbc288ad9d2a0 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc"
	@${RM} ${OBJECTDIR}/foc/an1078_smc.o.d
	@${RM} ${OBJECTDIR}/foc/an1078_smc.o
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_smc.c  -o ${OBJECTDIR}/foc/an1078_smc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_smc.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"

${OBJECTDIR}/foc/an1078_sta.o: foc/an1078_sta.c  .generated_files/flags/default/9bfc56ea9f87872121f6b7a2dbffda0b6f8ef3b0 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc"
	@${RM} ${OBJECTDIR}/foc/an1078_sta.o.d
	@${RM} ${OBJECTDIR}/foc/an1078_sta.o
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/an1078_sta.c  -o ${OBJECTDIR}/foc/an1078_sta.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/an1078_sta.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"

${OBJECTDIR}/foc/back_emf_obs.o: foc/back_emf_obs.c  .generated_files/flags/default/b9973acaaba8fda476b5a2e3174820839a07575 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/back_emf_obs.o.d 
	@${RM} ${OBJECTDIR}/foc/back_emf_obs.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/back_emf_obs.c  -o ${OBJECTDIR}/foc/back_emf_obs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/back_emf_obs.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/clarke.o: foc/clarke.c  .generated_files/flags/default/5b84bd4216a3013e0accd5d42c40e5bcc9e0df53 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/clarke.o.d 
	@${RM} ${OBJECTDIR}/foc/clarke.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/clarke.c  -o ${OBJECTDIR}/foc/clarke.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/clarke.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/flux_estimator.o: foc/flux_estimator.c  .generated_files/flags/default/1f2ae48fd2dc7077070b729719749b279e72cec3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/flux_estimator.o.d 
	@${RM} ${OBJECTDIR}/foc/flux_estimator.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/flux_estimator.c  -o ${OBJECTDIR}/foc/flux_estimator.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/flux_estimator.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_control.o: foc/foc_v2_control.c  .generated_files/flags/default/6c9e405fbf48ba2463e3e53f49d6c1250847dcc5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_control.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_control.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_control.c  -o ${OBJECTDIR}/foc/foc_v2_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_control.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_detect.o: foc/foc_v2_detect.c  .generated_files/flags/default/4a083ec13c8f39e45c5e41f0702a055037fa9e93 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_detect.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_detect.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_detect.c  -o ${OBJECTDIR}/foc/foc_v2_detect.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_detect.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_observer.o: foc/foc_v2_observer.c  .generated_files/flags/default/2f24f455d514ce57846dd12725a75f7af3266d0d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_observer.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_observer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_observer.c  -o ${OBJECTDIR}/foc/foc_v2_observer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_observer.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v2_pi.o: foc/foc_v2_pi.c  .generated_files/flags/default/f4335870905acef9b0b9144de32ab482427d62d6 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v2_pi.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v2_pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v2_pi.c  -o ${OBJECTDIR}/foc/foc_v2_pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v2_pi.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v3_control.o: foc/foc_v3_control.c  .generated_files/flags/default/a1b15defc7720dbd860fc586055d7a66d2e88580 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v3_control.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v3_control.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v3_control.c  -o ${OBJECTDIR}/foc/foc_v3_control.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v3_control.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/foc_v3_smo.o: foc/foc_v3_smo.c  .generated_files/flags/default/4baecb17a555b88c19ce0eab249ae25281b42242 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/foc_v3_smo.o.d 
	@${RM} ${OBJECTDIR}/foc/foc_v3_smo.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/foc_v3_smo.c  -o ${OBJECTDIR}/foc/foc_v3_smo.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/foc_v3_smo.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/mxlemming_obs.o: foc/mxlemming_obs.c  .generated_files/flags/default/a1204464b7b616d69ef3b2ef731b2c45a2539835 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/mxlemming_obs.o.d 
	@${RM} ${OBJECTDIR}/foc/mxlemming_obs.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/mxlemming_obs.c  -o ${OBJECTDIR}/foc/mxlemming_obs.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/mxlemming_obs.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/park.o: foc/park.c  .generated_files/flags/default/db6d97bbc26c27a2770bfa1fdd0d1c620ccfde6c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/park.o.d 
	@${RM} ${OBJECTDIR}/foc/park.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/park.c  -o ${OBJECTDIR}/foc/park.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/park.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/pi_controller.o: foc/pi_controller.c  .generated_files/flags/default/7e0f1753f80dbe3939ea93e885087d0ea3a3a5a4 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/pi_controller.o.d 
	@${RM} ${OBJECTDIR}/foc/pi_controller.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/pi_controller.c  -o ${OBJECTDIR}/foc/pi_controller.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/pi_controller.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/pll_estimator.o: foc/pll_estimator.c  .generated_files/flags/default/d539ef72a8394335c88c4f2006dc4f0c4dfa6186 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/pll_estimator.o.d 
	@${RM} ${OBJECTDIR}/foc/pll_estimator.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/pll_estimator.c  -o ${OBJECTDIR}/foc/pll_estimator.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/pll_estimator.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/smo_observer.o: foc/smo_observer.c  .generated_files/flags/default/14ecb12718e81806693c26575cb33a1885cdff71 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/smo_observer.o.d 
	@${RM} ${OBJECTDIR}/foc/smo_observer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/smo_observer.c  -o ${OBJECTDIR}/foc/smo_observer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/smo_observer.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/foc/svpwm.o: foc/svpwm.c  .generated_files/flags/default/59f30bc5e3ee2972ce4d8f5ff499e115fc2b18b2 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/foc" 
	@${RM} ${OBJECTDIR}/foc/svpwm.o.d 
	@${RM} ${OBJECTDIR}/foc/svpwm.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  foc/svpwm.c  -o ${OBJECTDIR}/foc/svpwm.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/foc/svpwm.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/garuda_service.o: garuda_service.c  .generated_files/flags/default/fb6c6a350d1d9bf000bdcc8b7d3a3e5e78fcf357 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/garuda_service.o.d 
	@${RM} ${OBJECTDIR}/garuda_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  garuda_service.c  -o ${OBJECTDIR}/garuda_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/garuda_service.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp.o: gsp/gsp.c  .generated_files/flags/default/38b522281118d2d07b7dbdd5668e3b7fa95d312c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp.c  -o ${OBJECTDIR}/gsp/gsp.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_commands.o: gsp/gsp_commands.c  .generated_files/flags/default/b62032c578e97367f627283a5457bdb873795f66 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_commands.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_commands.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_commands.c  -o ${OBJECTDIR}/gsp/gsp_commands.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_commands.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_params.o: gsp/gsp_params.c  .generated_files/flags/default/b6fbd9cd404b4858685ec496da31132e981a3e3f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_params.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_params.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_params.c  -o ${OBJECTDIR}/gsp/gsp_params.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_params.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/gsp/gsp_snapshot.o: gsp/gsp_snapshot.c  .generated_files/flags/default/49b7e4dbd951e5c3a243125e77bd123a3a1f5693 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/gsp" 
	@${RM} ${OBJECTDIR}/gsp/gsp_snapshot.o.d 
	@${RM} ${OBJECTDIR}/gsp/gsp_snapshot.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  gsp/gsp_snapshot.c  -o ${OBJECTDIR}/gsp/gsp_snapshot.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/gsp/gsp_snapshot.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/board_service.o: hal/board_service.c  .generated_files/flags/default/f8e44aa13bd449d8afe862f3c95dc3ec78b680e1 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/board_service.o.d 
	@${RM} ${OBJECTDIR}/hal/board_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/board_service.c  -o ${OBJECTDIR}/hal/board_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/board_service.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/clock.o: hal/clock.c  .generated_files/flags/default/587e44b4199d988bae0d7eed4f8e0620bbb7e17e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/clock.o.d 
	@${RM} ${OBJECTDIR}/hal/clock.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/clock.c  -o ${OBJECTDIR}/hal/clock.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/clock.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/device_config.o: hal/device_config.c  .generated_files/flags/default/69571426bbf57747b00018acdef98c1e50878a1c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/device_config.o.d 
	@${RM} ${OBJECTDIR}/hal/device_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/device_config.c  -o ${OBJECTDIR}/hal/device_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/device_config.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/eeprom.o: hal/eeprom.c  .generated_files/flags/default/5ffa900301dffc2bb03429c1ed8f7764cf9e9920 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/eeprom.o.d 
	@${RM} ${OBJECTDIR}/hal/eeprom.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/eeprom.c  -o ${OBJECTDIR}/hal/eeprom.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/eeprom.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_adc.o: hal/hal_adc.c  .generated_files/flags/default/125016b7a9a047c622b18a4781e57be62698d9fa .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_adc.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_adc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_adc.c  -o ${OBJECTDIR}/hal/hal_adc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_adc.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_ata6847.o: hal/hal_ata6847.c  .generated_files/flags/default/ffddedfa1525e0d89b810755b50d4173f2a1804a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_ata6847.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_ata6847.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_ata6847.c  -o ${OBJECTDIR}/hal/hal_ata6847.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_ata6847.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_input_capture.o: hal/hal_input_capture.c  .generated_files/flags/default/e56862ce93c821d16d730713bc383903765d5bdf .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_input_capture.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_input_capture.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_input_capture.c  -o ${OBJECTDIR}/hal/hal_input_capture.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_input_capture.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_pwm.o: hal/hal_pwm.c  .generated_files/flags/default/97a950992069eaf99cb8007545f9aee553427efd .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_pwm.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_pwm.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_pwm.c  -o ${OBJECTDIR}/hal/hal_pwm.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_pwm.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_spi.o: hal/hal_spi.c  .generated_files/flags/default/7b012e5437dd4262582b5c53ab01fe2bb530b58f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_spi.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_spi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_spi.c  -o ${OBJECTDIR}/hal/hal_spi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_spi.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_timer.o: hal/hal_timer.c  .generated_files/flags/default/7bf00ed5afe21b120aedb2067fdaab3f7e7e704e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_timer.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_timer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_timer.c  -o ${OBJECTDIR}/hal/hal_timer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_timer.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/hal_zcd.o: hal/hal_zcd.c  .generated_files/flags/default/d42761e30e0c72476038d807490bb7c0da02bf81 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/hal_zcd.o.d 
	@${RM} ${OBJECTDIR}/hal/hal_zcd.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/hal_zcd.c  -o ${OBJECTDIR}/hal/hal_zcd.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/hal_zcd.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/port_config.o: hal/port_config.c  .generated_files/flags/default/bc27797a6c99546be1bbc0b23305de4e96249ee7 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/port_config.o.d 
	@${RM} ${OBJECTDIR}/hal/port_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/port_config.c  -o ${OBJECTDIR}/hal/port_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/port_config.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/timer1.o: hal/timer1.c  .generated_files/flags/default/dbd6dc6b537013505d0c49c2ebb357781a213263 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/timer1.o.d 
	@${RM} ${OBJECTDIR}/hal/timer1.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/timer1.c  -o ${OBJECTDIR}/hal/timer1.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/timer1.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/hal/uart1.o: hal/uart1.c  .generated_files/flags/default/e965627aa19b3ab949d203eac0195d8a74887742 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/hal" 
	@${RM} ${OBJECTDIR}/hal/uart1.o.d 
	@${RM} ${OBJECTDIR}/hal/uart1.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  hal/uart1.c  -o ${OBJECTDIR}/hal/uart1.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/hal/uart1.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/input/rx_decode.o: input/rx_decode.c  .generated_files/flags/default/41b84053be4cf7dfecf1d1961c2481536efbad5e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/input" 
	@${RM} ${OBJECTDIR}/input/rx_decode.o.d 
	@${RM} ${OBJECTDIR}/input/rx_decode.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  input/rx_decode.c  -o ${OBJECTDIR}/input/rx_decode.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/input/rx_decode.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/adaptation.o: learn/adaptation.c  .generated_files/flags/default/4cc07b1d8adb93f6daf941c941eaabc9ad6e152b .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/adaptation.o.d 
	@${RM} ${OBJECTDIR}/learn/adaptation.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/adaptation.c  -o ${OBJECTDIR}/learn/adaptation.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/adaptation.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/commission.o: learn/commission.c  .generated_files/flags/default/271635ae59592c49586737e0b55412bc48fdd055 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/commission.o.d 
	@${RM} ${OBJECTDIR}/learn/commission.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/commission.c  -o ${OBJECTDIR}/learn/commission.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/commission.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/health.o: learn/health.c  .generated_files/flags/default/f0ba50f41b24b5bdd7a54f3df954ae8a865e0df8 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/health.o.d 
	@${RM} ${OBJECTDIR}/learn/health.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/health.c  -o ${OBJECTDIR}/learn/health.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/health.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/learn_service.o: learn/learn_service.c  .generated_files/flags/default/69cbefbdd2f3cbfb251e9dcd3354e6042d9ad13f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/learn_service.o.d 
	@${RM} ${OBJECTDIR}/learn/learn_service.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/learn_service.c  -o ${OBJECTDIR}/learn/learn_service.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/learn_service.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/quality.o: learn/quality.c  .generated_files/flags/default/3ecc23d0b6a33adad9bd8e7fdfc6b7f686266ab3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/quality.o.d 
	@${RM} ${OBJECTDIR}/learn/quality.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/quality.c  -o ${OBJECTDIR}/learn/quality.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/quality.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/learn/ring_buffer.o: learn/ring_buffer.c  .generated_files/flags/default/b8c7cdd7718830d72528208e98e59855461535ba .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/learn" 
	@${RM} ${OBJECTDIR}/learn/ring_buffer.o.d 
	@${RM} ${OBJECTDIR}/learn/ring_buffer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  learn/ring_buffer.c  -o ${OBJECTDIR}/learn/ring_buffer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/learn/ring_buffer.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/main.o: main.c  .generated_files/flags/default/371a6a1fced018acaf97298264ac7c663d14a1e7 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/main.o.d 
	@${RM} ${OBJECTDIR}/main.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  main.c  -o ${OBJECTDIR}/main.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/main.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/bemf_zc.o: motor/bemf_zc.c  .generated_files/flags/default/278107aa6a2acef96c4c82ca948d7f67ed6f7b21 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/bemf_zc.o.d 
	@${RM} ${OBJECTDIR}/motor/bemf_zc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/bemf_zc.c  -o ${OBJECTDIR}/motor/bemf_zc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/bemf_zc.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/commutation.o: motor/commutation.c  .generated_files/flags/default/669d0a9f62f9e67f9a1d5ca09eb3b231698a4864 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/commutation.o.d 
	@${RM} ${OBJECTDIR}/motor/commutation.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/commutation.c  -o ${OBJECTDIR}/motor/commutation.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/commutation.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/hwzc.o: motor/hwzc.c  .generated_files/flags/default/6b3ae17ae4bcd187bba26b8445964cd4e4505eb3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/hwzc.o.d 
	@${RM} ${OBJECTDIR}/motor/hwzc.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/hwzc.c  -o ${OBJECTDIR}/motor/hwzc.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/hwzc.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/pi.o: motor/pi.c  .generated_files/flags/default/737833f9fe816e2644cee421910d967a5d2a5933 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/pi.o.d 
	@${RM} ${OBJECTDIR}/motor/pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/pi.c  -o ${OBJECTDIR}/motor/pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/pi.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/speed_pi.o: motor/speed_pi.c  .generated_files/flags/default/ee451925f77e8d840a542e59587af70fb25d863d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/speed_pi.o.d 
	@${RM} ${OBJECTDIR}/motor/speed_pi.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/speed_pi.c  -o ${OBJECTDIR}/motor/speed_pi.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/speed_pi.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/motor/startup.o: motor/startup.c  .generated_files/flags/default/e9032c6cff9f4477d643f50ca67a53ad60f5a5b3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/motor" 
	@${RM} ${OBJECTDIR}/motor/startup.o.d 
	@${RM} ${OBJECTDIR}/motor/startup.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  motor/startup.c  -o ${OBJECTDIR}/motor/startup.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/motor/startup.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/scope/scope_burst.o: scope/scope_burst.c  .generated_files/flags/default/c0ac448470eefe698e1085a24e919fb8e9c63103 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/scope" 
	@${RM} ${OBJECTDIR}/scope/scope_burst.o.d 
	@${RM} ${OBJECTDIR}/scope/scope_burst.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  scope/scope_burst.c  -o ${OBJECTDIR}/scope/scope_burst.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MP -MMD -MF "${OBJECTDIR}/scope/scope_burst.o.d"        -g -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -O1 -I"hal" -I"motor" -I"gsp" -I"learn" -I"input" -I"scope" -I"x2cscope" -I"foc" -I"." -msmart-io=1 -Wall -msfr-warn=off    -mdfp="${DFP_DIR}/xc16"
	
${OBJECTDIR}/x2cscope/diagnostics.o: x2cscope/diagnostics.c  .generated_files/flags/default/82d399dcaf51a66f40cdbdfd86be6e0664083bb6 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
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
${DISTDIR}/garuda-ese-pristine.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o ${DISTDIR}/garuda-ese-pristine.${IMAGE_TYPE}.${OUTPUT_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}      -mcpu=$(MP_PROCESSOR_OPTION)        -D__DEBUG=__DEBUG -D__MPLAB_DEBUGGER_PK5=1  -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)      -Wl,,,--defsym=__MPLAB_BUILD=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,-D__DEBUG=__DEBUG,--defsym=__MPLAB_DEBUGGER_PK5=1,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--no-gc-sections,--fill-upper=0,--stackguard=16,--ivt,--isr,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem,--memorysummary,${DISTDIR}/memoryfile.xml$(MP_EXTRA_LD_POST)  -mdfp="${DFP_DIR}/xc16" 
	
else
${DISTDIR}/garuda-ese-pristine.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o ${DISTDIR}/garuda-ese-pristine.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}      -mcpu=$(MP_PROCESSOR_OPTION)        -omf=elf -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wl,,,--defsym=__MPLAB_BUILD=1,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--no-gc-sections,--fill-upper=0,--stackguard=16,--ivt,--isr,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem,--memorysummary,${DISTDIR}/memoryfile.xml$(MP_EXTRA_LD_POST)  -mdfp="${DFP_DIR}/xc16" 
	${MP_CC_DIR}/xc-dsc-bin2hex ${DISTDIR}/garuda-ese-pristine.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX} -a  -omf=elf   -mdfp="${DFP_DIR}/xc16" 
	
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
