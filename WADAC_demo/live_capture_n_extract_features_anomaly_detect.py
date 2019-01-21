#!/usr/bin/python
from scapy.all import *
import numpy as np
import copy
import sqlite3 as lite
import os
import os.path
import time
import shutil as su
from collections import Counter
import csv
import pandas as pd


def read_packs_from_file(fname):
    #print('reading packets from file = ', fname)
    myreader = PcapReader(fname)
    return myreader
def get_feats_names_set(max_pkt_size,bin_length):
    bins_count = int(max_pkt_size / bin_length) + 1

    features_names_sr = ['t_mac','t_label','c_blk_sz','f_time_fstframe','f_time_window']
    features_names_sr += ['c_c_mx','f_fr_mx_x','c_c_mx_us','f_mn_mx_xs','f_sd_mx_xs']
    features_names_sr += ['c_c_cx','f_fr_cx_x','c_c_cx_us','f_mn_cx_xs','f_sd_cx_xs']
    features_names_sr += ['c_c_dx','f_fr_dx_x','c_c_dx_us','f_mn_dx_xs','f_sd_dx_xs']
    fts_str = ['c_c_dx_b','f_fr_dx_tb_b','f_mn_xs_dx_b','f_sd_xs_dx_b','f_mn_tg_dx_b','f_sd_tg_dx_b']

    for i in np.arange(bins_count):
        for fts in fts_str:
            feat_name = fts+str(int(i))
            #print(feat_name)
            features_names_sr.append(feat_name)

    features_names_s = ['t_mac','t_label','c_blk_sz','f_time_fstframe','f_time_window']
    features_names_s += ['c_c_ms','f_fr_ms_mx','c_c_ms_us','f_mn_ms_xs','f_sd_ms_xs']
    features_names_s += ['c_c_cs','f_fr_cs_cx','c_c_cs_us','f_mn_cs_xs','f_sd_cs_xs']
    features_names_s += ['c_c_ds','f_fr_ds_dx','c_c_ds_us','f_mn_ds_xs','f_sd_ds_xs']
    #feat_str = ['c_c_ds_b_','f_fr_ds_tb_b_','f_mn_xs_ds_b_','f_sd_xs_ds_b_','f_mn_tg_ds_b_','f_sd_tg_ds_b_']
    fts_str = ['c_c_ds_b','f_fr_ds_tb_b','f_mn_xs_ds_b','f_sd_xs_ds_b','f_mn_tg_ds_b','f_sd_tg_ds_b']

    for i in np.arange(bins_count):
        for fts in fts_str:
            feat_name = fts+str(int(i))
            features_names_s.append(feat_name)

    features_names_r = ['t_mac','t_label','c_blk_sz','f_time_fstframe','f_time_window']
    features_names_r += ['c_c_mr','f_fr_mr_mx','c_c_mr_us','f_mn_mr_xs','f_sd_mr_xs']
    features_names_r += ['c_c_cr','f_fr_cr_cx','c_c_cr_us','f_mn_cr_xs','f_sd_cr_xs']
    features_names_r += ['c_c_dr','f_fr_dr_dx','c_c_dr_us','f_mn_dr_xs','f_sd_dr_xs']
    #feat_str = ['c_c_dr_b_','f_fr_dr_tb_b_','f_mn_xs_dr_b_','f_sd_xs_dr_b_','f_mn_tg_dr_b_','f_sd_tg_dr_b_']
    fts_str = ['c_c_dr_b','f_fr_dr_tb_b','f_mn_xs_dr_b','f_sd_xs_dr_b','f_mn_tg_dr_b','f_sd_tg_dr_b']

    for i in np.arange(bins_count):
        for fts in fts_str:
            feat_name = fts+str(int(i))
            features_names_r.append(feat_name)
    return([features_names_sr,features_names_s,features_names_r])

def create_database(bin_length,max_pkt_size,db_name,tab_name_traffic_features,tab_name_packet_features):
    conek = lite.connect(db_name)
    csor = conek.cursor()
    #print('creating table : ', table_name,' fts_list = ', fts_list[0])
    bins_count = int(max_pkt_size / bin_length) + 1

    feats_sets_names = get_feats_names_set(max_pkt_size,bin_length)
    #####################  for all data frames ################################
    #features_names_sr = ['t_mac','t_label','c_blk_sz','f_time_fstframe','f_time_window']
    #features_names_sr += ['c_c_mx','f_fr_mx_x','c_c_mx_us','f_mn_mx_xs','f_sd_mx_xs']
    #features_names_sr += ['c_c_cx','f_fr_cx_x','c_c_cx_us','f_mn_cx_xs','f_sd_cx_xs']
    #features_names_sr += ['c_c_dx','f_fr_dx_x','c_c_dx_us','f_mn_dx_xs','f_sd_dx_xs']
    #fts_str = ['c_c_dx_b','f_fr_dx_tb_b','f_mn_xs_dx_b','f_sd_xs_dx_b','f_mn_tg_dx_b','f_sd_tg_dx_b']

    #for i in np.arange(bins_count):
        # for fts in fts_str:
        #     feat_name = fts+str(int(i))
        #     #print(feat_name)
        #     features_names_sr.append(feat_name)
    features_names_sr =  feats_sets_names[0]
    stmt1 = 'create table if not exists ' + tab_name_traffic_features+'_all_dframes('
    tot_ft = len(features_names_sr)
    #print('features count in all_dframes = ',tot_ft)
    for index in range(tot_ft - 1):
        if features_names_sr[index][0] == 't':
            stmt1 += features_names_sr[index] + ' text, '
        if features_names_sr[index][0] == 'c':
            stmt1 += features_names_sr[index] + ' int, '
        if features_names_sr[index][0] == 'f':
            stmt1 += features_names_sr[index] + ' real, '
    #for the last column
    if features_names_sr[index + 1][0] == 't':
        stmt1 += features_names_sr[index + 1] + ' text)'
    if features_names_sr[index + 1][0] == 'c':
        stmt1 += features_names_sr[index + 1] + ' int)'
    if features_names_sr[index + 1][0] == 'f':
        stmt1 += features_names_sr[index + 1] + ' real)'

    #print(stmt1)
    csor.execute(stmt1)
    ################### for sent data frames #######################################
    # features_names_s = ['t_mac','t_label','c_blk_sz','f_time_fstframe','f_time_window']
    # features_names_s += ['c_c_ms','f_fr_ms_mx','c_c_ms_us','f_mn_ms_xs','f_sd_ms_xs']
    # features_names_s += ['c_c_cs','f_fr_cs_cx','c_c_cs_us','f_mn_cs_xs','f_sd_cs_xs']
    # features_names_s += ['c_c_ds','f_fr_ds_dx','c_c_ds_us','f_mn_ds_xs','f_sd_ds_xs']
    # #feat_str = ['c_c_ds_b_','f_fr_ds_tb_b_','f_mn_xs_ds_b_','f_sd_xs_ds_b_','f_mn_tg_ds_b_','f_sd_tg_ds_b_']
    # fts_str = ['c_c_ds_b','f_fr_ds_tb_b','f_mn_xs_ds_b','f_sd_xs_ds_b','f_mn_tg_ds_b','f_sd_tg_ds_b']
    #
    # for i in np.arange(bins_count):
    #     for fts in fts_str:
    #         feat_name = fts+str(int(i))
    #         features_names_s.append(feat_name)

    features_names_s =  feats_sets_names[1]
    stmt1 = 'create table if not exists ' + tab_name_traffic_features+'_sent_dframes('
    tot_ft = len(features_names_s)
    #print('features count in sent_dframes = ',tot_ft)
    for index in range(tot_ft - 1):
        if features_names_s[index][0] == 't':
            stmt1 += features_names_s[index] + ' text, '
        if features_names_s[index][0] == 'c':
            stmt1 += features_names_s[index] + ' int, '
        if features_names_s[index][0] == 'f':
            stmt1 += features_names_s[index] + ' real, '
    #for the last column
    if features_names_s[index + 1][0] == 't':
        stmt1 += features_names_s[index + 1] + ' text)'
    if features_names_s[index + 1][0] == 'c':
        stmt1 += features_names_s[index + 1] + ' int)'
    if features_names_s[index + 1][0] == 'f':
        stmt1 += features_names_s[index + 1] + ' real)'

    #print(stmt1)
    csor.execute(stmt1)
    ###################  recv data frames ######################
    # features_names_r = ['t_mac','t_label','c_blk_sz','f_time_fstframe','f_time_window']
    # features_names_r += ['c_c_mr','f_fr_mr_mx','c_c_mr_us','f_mn_mr_xs','f_sd_mr_xs']
    # features_names_r += ['c_c_cr','f_fr_cr_cx','c_c_cr_us','f_mn_cr_xs','f_sd_cr_xs']
    # features_names_r += ['c_c_dr','f_fr_dr_dx','c_c_dr_us','f_mn_dr_xs','f_sd_dr_xs']
    # #feat_str = ['c_c_dr_b_','f_fr_dr_tb_b_','f_mn_xs_dr_b_','f_sd_xs_dr_b_','f_mn_tg_dr_b_','f_sd_tg_dr_b_']
    # fts_str = ['c_c_dr_b','f_fr_dr_tb_b','f_mn_xs_dr_b','f_sd_xs_dr_b','f_mn_tg_dr_b','f_sd_tg_dr_b']
    #
    # for i in np.arange(bins_count):
    #     for fts in fts_str:
    #         feat_name = fts+str(int(i))
    #         features_names_r.append(feat_name)

    features_names_r =  feats_sets_names[2]
    stmt1 = 'create table if not exists ' + tab_name_traffic_features+'_recv_dframes('
    tot_ft = len(features_names_r)
    #print('features count in recv_dframes = ',tot_ft)
    for index in range(tot_ft - 1):
        if features_names_r[index][0] == 't':
            stmt1 += features_names_r[index] + ' text, '
        if features_names_r[index][0] == 'c':
            stmt1 += features_names_r[index] + ' int, '
        if features_names_r[index][0] == 'f':
            stmt1 += features_names_r[index] + ' real, '
    #for the last column
    if features_names_r[index + 1][0] == 't':
        stmt1 += features_names_r[index + 1] + ' text)'
    if features_names_r[index + 1][0] == 'c':
        stmt1 += features_names_r[index + 1] + ' int)'
    if features_names_r[index + 1][0] == 'f':
        stmt1 += features_names_r[index + 1] + ' real)'

    #print(stmt1)
    csor.execute(stmt1)

    #####################################################################
    #create basic packet feature table
    stmt = 'create table if not exists ' + tab_name_packet_features+'('
    stmt += 'label text, '
    stmt += 'pkt_no int, '
    stmt += 'a1 text, '
    stmt += 'a2 text, '
    stmt += 'a3 text, '
    stmt += 'a4 text, '
    stmt += 'src_mac text, '
    stmt += 'dst_mac text, '
    stmt += 'tr_mac text, '
    stmt += 'rc_mac text, '
    stmt += 'size int, '
    stmt += 'tp int, '
    stmt += 'subtp int,'
    stmt += 'to_ds int,'
    stmt += 'from_ds int,'
    stmt += 'mf int, '
    stmt += 'retry int, '
    stmt += 'pw_mgmt int,'
    stmt += 'md int,'
    stmt += 'protect int,'
    stmt += 'sn int, '
    stmt += 'fn int, '
    stmt += 'p_time real,'
    stmt += 'sig_strength int,'
    stmt += 'dur int'
    stmt += ')'
    csor.execute(stmt)
    conek.commit()
    conek.close()
    #print('created table: ', table_name)
    return([features_names_sr,features_names_s,features_names_r])
##############################################################################
#  extract and store packet features into database
##############################################################################
def getUnicodeToAscii(unicodeStr):
    mac_addr = unicodeStr.encode('ascii','replace')
    #print('unicodeStr : ',unicodeStr, ' mac_addr  : ',mac_addr)
    return(mac_addr)
def store_packet_features(pkts,db_name,tab_name_packet_features,label):
    conek = lite.connect(db_name)
    csor = conek.cursor()


    packets_count = len(pkts)
    #total_packets_count += packets_count
    window_size = pkts[packets_count-1].time - pkts[0].time
    print(' pcap_fname = ',label,
    '  #packets = ',packets_count,
    ' t(1st pkt) = ', pkts[0].time,
    ' t(n-th pack) = ', pkts[packets_count-1].time,
    ' window_size = ',window_size)
    i = 0
    for pkt in pkts:
        #if i == 30084:
        #    print("pkt number = ",i, ' pkt: ',pkt)
        #print(pkt.addr1, pkt.addr2,pkt.addr3,pkt.addr4)
        i += 1
        #pkt_dot11 = Dot11(pkt)
        if Dot11 not in pkt: #or pkt.haslayer(Dot11)
            print('mal formed packet --------- pkt no. : ',i)
            continue
        a1 = getUnicodeToAscii(str(pkt.addr1))
        a2 = getUnicodeToAscii(str(pkt.addr2))
        a3 = getUnicodeToAscii(str(pkt.addr3))
        a4 = getUnicodeToAscii(str(pkt.addr4))
        p_len = len(pkt)
        rtPres = pkt[RadioTap].present
        rtNotDecoded = pkt[RadioTap].notdecoded
        d11Tp = ''
        d11Stp = ''
        DS = pkt[Dot11].FCfield & 0x3
        to_ds = DS & 0x1
        from_ds = DS & 0x2

        src_mac = ''
        dst_mac = ''
        tr_mac = ''
        rc_mac = ''
        if to_ds == 0 and from_ds == 0:
            dst_mac = a1
            src_mac = a2
            rc_mac = a1
            tr_mac = a2
        if to_ds != 0 and from_ds == 0:
            src_mac = a2
            dst_mac = a1
            tr_mac = a2
            rc_mac = a3
        if to_ds == 0 and from_ds != 0:
            dst_mac = a1
            src_mac = a2
            tr_mac = a2
            rc_mac = a3
        if to_ds != 0 and from_ds != 0:
            dst_mac = a3
            src_mac = a4
            tr_mac = a2
            rc_mac = a1

        mf = int(pkt[Dot11].FCfield & 4)
        retry = int(pkt[Dot11].FCfield & 8)
        p_mgmt = int(pkt[Dot11].FCfield & 16)
        md = int(pkt[Dot11].FCfield & 32)
        protect = int(pkt[Dot11].FCfield & 64)
        order = int(pkt[Dot11].FCfield & 128)
        #if i == 127:
            #print('i = ', i, ' FC = ', "{0:b}".format(pkt[Dot11].FCfield),' to_DS = ',to_ds, '  from_ds = ', from_ds)
            #print('       a1 = ',a1, ' a2 = ', a2, ' a3 = ',a3, ' a4 = ',a4, '  src_mac = ',src_mac, '  dst_mac =', dst_mac,'  tr_mac = ', tr_mac,'  rc_mac = ',rc_mac)

        #    print('i= ', i, "  mf = ", mf, '  retry = ', retry, '  protect = ',protect, ' order= ', order)
        #    break

        sc = 0
        fn = 0
        sn = 0
        if pkt[Dot11].SC :
            s = bin(pkt[Dot11].SC)[2:]
            s = ('0' * (16 - len(s)) + s)
            fn = int(s[:-4], 2)
            sn = int(s[-4:], 2)
            sc = pkt[Dot11].SC
        tm = pkt.time
        ##mgmt : assocreq - maq, assocresp - mas, reassocreq - mrq , reassocresp - mrs, probereq - mpq, proberesp - mps,
        ##mgmt : beacon - mbn, atim - mtm, disassoc - mda, auth - mah, deauth - mdh, resv_ - mrv
        #subtp_mgmt = ['assocreq','assocresp','reassocreq','reassocresp','probereq','beacon','atim','disassoc','auth','deauth','mresv']
        if pkt[Dot11].type == 0:
            d11Tp = 'mgmt'
            if pkt[Dot11].subtype == 0:
                d11Stp = 'assocreq'
            if pkt[Dot11].subtype == 1:
                d11Stp = 'assocresp'
            if pkt[Dot11].subtype == 2:
                d11Stp = 'reassocreq'
            if pkt[Dot11].subtype == 3:
                d11Stp = 'reassocresp'
            if pkt[Dot11].subtype == 4:
                d11Stp = 'probereq'
            if pkt[Dot11].subtype == 5:
                d11Stp = 'proberesp'
            if pkt[Dot11].subtype == 8:
                d11Stp = 'beacon'
            if pkt[Dot11].subtype == 9:
                d11Stp = 'atim'
            if pkt[Dot11].subtype == 10:
                d11Stp = 'disassoc'
            if pkt[Dot11].subtype == 11:
                d11Stp = 'auth'
            if pkt[Dot11].subtype == 12:
                d11Stp = 'deauth'
            if pkt[Dot11].subtype > 12:
                d11Stp = 'mresv_'+ str(pkt[Dot11].subtype)
        ##ctrl : rts - crs, cts - ccs, resv_ - crv , ps_poll - cpp, cf_end - cce, cf_end_cf_ack - cceca
        #subtp_ctrl = ['cresv','ps_poll','rts','cts','ack','cf_end','cf_end_cf_ack']
        if pkt[Dot11].type == 1:
            d11Tp = 'ctrl'
            if pkt[Dot11].subtype < 10:
                d11Stp = 'cresv_'+ str(pkt[Dot11].subtype)
            if pkt[Dot11].subtype == 8:
                d11Stp = 'blk_ack'
            if pkt[Dot11].subtype == 10:
                d11Stp = 'ps_poll'
            if pkt[Dot11].subtype == 11:
                d11Stp = 'rts'
            if pkt[Dot11].subtype == 12:
                d11Stp = 'cts'
            if pkt[Dot11].subtype == 13:
                d11Stp = 'ack'
            if pkt[Dot11].subtype == 14:
                d11Stp = 'cf_end'
            if pkt[Dot11].subtype == 15:
                d11Stp = 'cf_end_cf_ack'
        ##data : data - dd, data_cf_ack - ddca, data_cf_poll - ddcp, data_cf_ack_cf_poll - ddcacp,
        ##data : no_data - dnd, cf_ack - dca, cf_poll - dcp , cf_ack_cf_poll - dcacp , resv_ -drv
        #subtp_data = ['data','data_cf_ack','data_cf_poll','data_cf_ack_cf_poll','no_data','cf_ack','cf_poll','cf_ack_cf_poll','dresv']
        if pkt[Dot11].type == 2:
            d11Tp = 'data'
            if pkt[Dot11].subtype == 0:
                d11Stp = 'data'
            if pkt[Dot11].subtype == 1:
                d11Stp = 'data_cf_ack'
            if pkt[Dot11].subtype == 2:
                d11Stp = 'data_cf_poll'
            if pkt[Dot11].subtype == 3:
                d11Stp = 'data_cf_ack_cf_poll'
            if pkt[Dot11].subtype == 4:
                d11Stp = 'no_data'
            if pkt[Dot11].subtype == 5:
                d11Stp = 'cf_ack'
            if pkt[Dot11].subtype == 6:
                d11Stp = 'cf_poll'
            if pkt[Dot11].subtype == 7:
                d11Stp = 'cf_ack_cf_poll'
            if pkt[Dot11].subtype > 7:
                d11Stp = 'dresv_' + str(pkt[Dot11].subtype)
        rowItems = list()
        rowItems.append(label)
        rowItems.append(i)
        rowItems.append(a1)
        rowItems.append(a2)
        rowItems.append(a3)
        rowItems.append(a4)
        rowItems.append(src_mac)
        rowItems.append(dst_mac)
        rowItems.append(tr_mac)
        rowItems.append(rc_mac)
        rowItems.append(p_len)
        rowItems.append(d11Tp)
        rowItems.append(d11Stp)
        rowItems.append(to_ds)
        rowItems.append(from_ds)
        rowItems.append(mf)
        rowItems.append(retry)
        rowItems.append(p_mgmt)
        rowItems.append(md)
        rowItems.append(protect)
        rowItems.append(sn)
        rowItems.append(fn)
        rowItems.append(tm)
        rowItems.append(0)
        rowItems.append(0)
        stmt = 'insert into ' + tab_name_packet_features
        stmt += ' values('
        for it in rowItems[:-1]:
            stmt+= '?,'
        stmt += '?)'
        csor.execute(stmt,rowItems)

    conek.commit()
    conek.close()
######################################################################
#  End extract packet features
######################################################################
def get_type_based_size_lists(mac,pkt_reader):
    total_pkt_count =0
    d_fr_list = list()
    c_fr_list = list()
    m_fr_list = list()
    m_sent_list = list()
    m_recv_list = list()
    c_sent_list = list()
    c_recv_list = list()
    d_sent_list = list()
    d_recv_list = list()
    ii = 0
    for pkt in pkt_reader:
        data_sz = 0
        ctrl_sz = 0
        mgmt_sz = 0
        total_pkt_count += 1
        #to decide if sent of recv
        a1byte = getUnicodeToAscii(str(pkt.addr1))
        a1 = a1byte.decode('utf-8')
        a2byte = getUnicodeToAscii(str(pkt.addr2))
        a2 = a2byte.decode('utf-8')
        a3byte = getUnicodeToAscii(str(pkt.addr3))
        a3 = a3byte.decode('utf-8')
        a4byte = getUnicodeToAscii(str(pkt.addr4))
        a4 = a4byte.decode('utf-8')
        DS = pkt[Dot11].FCfield & 0x3
        to_ds = DS & 0x1
        from_ds = DS & 0x2

        src_mac = ''
        dst_mac = ''
        tr_mac = ''
        rc_mac = ''
        if to_ds == 0 and from_ds == 0:
            dst_mac = a1
            src_mac = a2
            rc_mac = a1
            tr_mac = a2

        if to_ds != 0 and from_ds == 0:
            src_mac = a2
            dst_mac = a1
            tr_mac = a2
            rc_mac = a3
        if to_ds == 0 and from_ds != 0:
            dst_mac = a1
            src_mac = a2
            tr_mac = a2
            rc_mac = a3
        if to_ds != 0 and from_ds != 0:
            dst_mac = a3
            src_mac = a4
            tr_mac = a2
            rc_mac = a1
        #print('src_mac = ',src_mac, ' tr_mac = ', tr_mac, ' dst_mac = ', dst_mac, ' rc_mac = ', rc_mac)
        if pkt.type==0: ## management
            mgmt_sz = len(pkt)
            m_fr_list.append(pkt)
            if mac == src_mac or mac == tr_mac:
                m_sent_list.append(pkt)
            elif mac == dst_mac or mac == rc_mac:
                m_recv_list.append(pkt)
            else:
                print('mgmt: not sent or not recv : pkt no: ',ii)
        if pkt.type==1:## control
            ctrl_sz = len(pkt)
            c_fr_list.append(pkt)
            if mac == src_mac or mac == tr_mac:
                c_sent_list.append(pkt)
            elif mac == dst_mac or mac == rc_mac:
                c_recv_list.append(pkt)
            else:
                print('ctrl: not sent or not recv: pkt no: ',ii, ' mac = ',mac, ' src = ', src_mac, ' tr = ', tr_mac, ' dst = ',dst_mac, ' rc = ',rc_mac)
                #print('pkt= ', pkt.show(),'  a1 = ',pkt.addr1,' a2 = ',pkt.addr2, ' a3 = ', pkt.addr3, ' a4 = ',pkt.addr4,' from_ds = ',from_ds, ' to_ds = ', to_ds)
        if pkt.type==2:## data
            data_sz = len(pkt)
            d_fr_list.append(pkt)
            if mac == src_mac or mac == tr_mac:
                d_sent_list.append(pkt)
            elif mac == dst_mac or mac == rc_mac:
                d_recv_list.append(pkt)
            else:
                print('data: not sent or not recv : pkt no. : ',ii,' mac = ',mac,' src_mac = ',src_mac, ' tr_mac = ', tr_mac, ' dst_mac= ', dst_mac, ' rc_mac = ', rc_mac)
        ii += 1
    #if len(d_fr_list) == 0:
    #    print('c(d_f) = ',len(d_fr_list),' c(c_f) = ',len(c_fr_list), ' c(m_f) = ',len(m_fr_list))
    ret_list = list()
    ret_list.append(m_fr_list)
    ret_list.append(m_sent_list)
    ret_list.append(m_recv_list)
    ret_list.append(c_fr_list)
    ret_list.append(c_sent_list)
    ret_list.append(c_recv_list)
    ret_list.append(d_fr_list)
    ret_list.append(d_sent_list)
    ret_list.append(d_recv_list)
    #print('len(m_fr_list) = ',len(m_fr_list),' len(m_sent_list) = ',len(m_sent_list),' len(m_recv_list)',len(m_recv_list))
    #print('len(c_fr_list) = ',len(c_fr_list), ' len(c_sent_list) = ',len(c_sent_list),' len(c_recv_list) = ',len(c_recv_list))
    #print('len(d_fr_list) = ',len(d_fr_list),' len(d_sent_list) = ',len(d_sent_list),' len(d_recv_list) = ',len(d_recv_list))
    return ret_list

def get_frame_sizes(all_frames):
    sizes_list = list()
    for pkt in all_frames:
        frame_size = len(pkt)
        sizes_list.append(frame_size)

    return sizes_list

def get_size_distribution(bin_length, max_pkt_size, size_list):
    total_pks_count = len(size_list)
    sz_count = Counter(size_list)
    #unique_sizes = np.unique(size_list)
    #print('considering only data frames: unique sizes count = ', len(unique_sizes),' total_data_frame_count = ',total_pks_count)
    #uniq_size_count_list = list()
    uniq_size_count_dic = {}
    mean_size_count_dic = {}
    std_size_count_dic = {}
    bins_count = int(max_pkt_size/bin_length) + 1
    i = 0
    total_in_dic = 0
    for u in sz_count:
        u_count = sz_count[u]
        #print('i = ',i,' u= ', u, ' u_count = ', u_count)
        part_sum1 = u_count * u
        #uniq_size_count_list.append(u_count)
        bin_index = -1
        if u < max_pkt_size:
            bin_index = int(u/bin_length)
            #print('i={0}, size = {1}, index = {2}'.format(i,u,bin_index))
        else:
            print('size (= {0} ) > max limit (= {1})'.format(u,max_pkt_size))

        if bin_index != -1:
            total_in_dic += u_count
            new_std = 0.0
            new_mean = 1.0 * u
            if bin_index in uniq_size_count_dic:
                old_count = uniq_size_count_dic[bin_index]
                new_count = old_count + u_count
                old_mean = mean_size_count_dic[bin_index]
                part_sum2 = old_count * old_mean
                new_mean = 1.0*(part_sum1 + part_sum2) / new_count
                #update the dics
                uniq_size_count_dic[bin_index] = new_count
                mean_size_count_dic[bin_index] = new_mean
                a = np.array([old_mean for i in range(old_count)])
                b = np.array([u for i in range(u_count)])
                new_std = np.sqrt((((a - new_mean)**2).sum() + ((b - new_mean)**2).sum())/new_count)
                std_size_count_dic[bin_index] = new_std
            else:
                uniq_size_count_dic[bin_index] = u_count
                mean_size_count_dic[bin_index] = new_mean
                std_size_count_dic[bin_index] = new_std
            #if new_std == 0.0:
            #    print(bin_index,u_count,new_mean, new_std)
        i += 1
    #for ld in uniq_size_count_dic:
    #    if uniq_size_count_dic[ld] != 0 and (std_size_count_dic[ld] == 0 or std_size_count_dic[ld] == 0.0):
    #        print('wrong: ',ld,uniq_size_count_dic[ld],mean_size_count_dic[ld],std_size_count_dic[ld])

    if total_in_dic != total_pks_count:
        print(' uniques  = ',i,' total = ',len(size_list), '  in bin: ', total_in_dic)
    #print(uniq_size_count_dic)
    return([total_in_dic,uniq_size_count_dic,mean_size_count_dic,std_size_count_dic])

def get_per_bin_load_fraction(bin_length, max_pkt_size, sz_dist_elem):
    bin_ld_list = list()
    bin_f_ld_list = list()
    mn_ld_list = list()
    sd_ld_list = list()

    total_in_dic = sz_dist_elem[0]
    uniq_size_count_dic = sz_dist_elem[1]
    mean_size_count_dic = sz_dist_elem[2]
    std_size_count_dic = sz_dist_elem[3]
    bins_count = int(max_pkt_size / bin_length) + 1
    #feat_str = ['c_c_dx_b_','f_fr_dx_tb_b_','f_mn_xs_dx_b_','f_sd_xs_dx_b_','f_mn_tg_dx_b_','f_sd_tg_dx_b_']
    for i in np.arange(0,bins_count):
        pkt_sz = i# * bin_length
        bin_ld = 0
        mn_ld = 0.0
        sd_ld = 0.0
        if pkt_sz in uniq_size_count_dic:
            bin_ld = uniq_size_count_dic[pkt_sz]
            mn_ld = mean_size_count_dic[pkt_sz]
            sd_ld = std_size_count_dic[pkt_sz]
        f_bin_ld = 0.0
        if total_in_dic > 0:
            f_bin_ld = 1.0 * bin_ld / total_in_dic
        bin_ld_list.append(bin_ld)
        bin_f_ld_list.append(f_bin_ld)
        mn_ld_list.append(mn_ld)
        sd_ld_list.append(sd_ld)
        #c_mn_ld = int(mn_ld)
        #delta = mn_ld - c_mn_ld
        #if bin_ld > 0 and delta > 0.0 and (sd_ld == 0.0):
        #    c_mn_ld = int(mn_ld)
        #    print( 'wrong : bid = ',i,' bin_ld = ', bin_ld, ' fr_ld = ',f_bin_ld,' mn_ld',mn_ld,' bin_sd = ', sd_ld)
        #print('bid = ',i,' bin_ld = ', bin_ld)
    return  [bin_ld_list,bin_f_ld_list,mn_ld_list,sd_ld_list]
def get_size_stat_per_bin(bin_length, max_pkt_size, sizes_list):
    param_lists1 = list()
    szs_count = len(sizes_list)
    bin_dict = dict()
    for sz in sizes_list:
        bin_index = -1
        if sz < max_pkt_size:
            bin_index = int(sz/bin_length)
            #print('i={0}, size = {1}, index = {2}'.format(i,u,bin_index))
            str_bi = str(bin_index)
            if str_bi in bin_dict:
                bin_dict[str_bi].append(sz)
            else:
                bin_dict[str_bi] = list()
                bin_dict[str_bi].append(sz)
        else:
            print('size (= {0} ) > max limit (= {1})'.format(u,max_pkt_size))
    #get bin stats
    bin_lds_list = list()
    fr_lds_list = list()
    mn_lds_list = list()
    sd_lds_list = list()

    bins_count = int(max_pkt_size / bin_length) + 1
    #feat_str = ['c_c_dx_b_','f_fr_dx_tb_b_','f_mn_xs_dx_b_','f_sd_xs_dx_b_','f_mn_tg_dx_b_','f_sd_tg_dx_b_']
    for bi in np.arange(0,bins_count):
        str_bi = str(bi)
        bn_ld = 0
        fr_ld = 0
        mn_ld = 0
        sd_ld = 0
        if str_bi in bin_dict:
            bn_ld = len(bin_dict[str_bi])
            fr_ld = bn_ld / szs_count
            mn_ld = np.mean(bin_dict[str_bi])
            sd_ld = np.std(bin_dict[str_bi])
        bin_lds_list.append(bn_ld)
        fr_lds_list.append(fr_ld)
        mn_lds_list.append(mn_ld)
        sd_lds_list.append(sd_ld)
    param_lists1.append(bin_lds_list)
    param_lists1.append(fr_lds_list)
    param_lists1.append(mn_lds_list)
    param_lists1.append(sd_lds_list)
    return(param_lists1)

def get_features_from_size_dist(bin_length,max_pkt_size,segregated_pkt_list):
    #for all data frames without direction
    #6 -- all frames, 7 -- sent frames , 8 -- recv frames
    all_lists_data = [segregated_pkt_list[6],segregated_pkt_list[7],segregated_pkt_list[8]]
    #print('len(all_lists_data[0]) = ',len(all_lists_data[0]),' len(all_lists_data[1]) = ',len(all_lists_data[1]), ' len(all_lists_data[2]) = ',len(all_lists_data[2]))
    ret_lists = list()
    for lst in all_lists_data:
        data_frames = lst
        sizes_list = get_frame_sizes(data_frames)
        #print('sizes list = ', sizes_list)
        #sz_dist_elem = get_size_distribution(bin_length, max_pkt_size, sizes_list)
        #param_lists = get_per_bin_load_fraction(bin_length, max_pkt_size,sz_dist_elem)
        param_lists1 = get_size_stat_per_bin(bin_length, max_pkt_size, sizes_list)
        #if (param_lists[0] != param_lists1[0]) or (param_lists[1] != param_lists1[1]):
        #    print('param_list[0] = ', param_lists[0], '  param_list1[0] = ', param_lists1[0])

        ret_lists.append(param_lists1)

    return ret_lists

def get_times_dic(bin_length,all_frames):
    times_dic = {}
    for pkt in all_frames:
        sz = len(pkt)
        bid = int(sz / bin_length)
        ti = pkt.time
        if bid in times_dic:
            times_list = times_dic[bid]
            times_list.append(ti)
        else:
            times_list = list()
            times_list.append(ti)
            times_dic[bid] = times_list
    return times_dic

def get_mean_std_time_gaps(bin_length,max_pkt_size,times_dic):
    mean_gaps_dic = {}
    std_gaps_dic = {}
    bins_count = int(max_pkt_size/bin_length) + 1
    for bi in np.arange(0,bins_count):
        mean_gap = 0.0
        std_gap = 0.0
        ti_count = 0
        if bi in times_dic:
            ti_list = times_dic[bi]
            # compute time gaps
            ti_count = len(ti_list)
            gaps_list = list()
            if ti_count > 1:
                t1 = ti_list[0]
                for i in np.arange(1,ti_count,1):
                    t2 = ti_list[i]
                    gap = t2 - t1
                    gaps_list.append(gap)
                mean_gap = np.mean(gaps_list)
                std_gap = np.std(gaps_list)

        #print('bi = ', bi, ' count = ',ti_count,' mean gap = ', mean_gap, '  std_gap = ',std_gap)
        mean_gaps_dic[bi]=mean_gap
        std_gaps_dic[bi]=std_gap
    return [mean_gaps_dic, std_gaps_dic]

def get_time_gaps_each_bin(bin_length,max_pkt_size,segregated_pkt_list):
    #compute time gaps for time gaps of frames without traffic direction
    frs_lists = [segregated_pkt_list[6],segregated_pkt_list[7],segregated_pkt_list[8]]
    ret_lists = list()
    for frs_list in frs_lists:
        #print('count d_frames = ', len(frs_list))
        times_dic = get_times_dic(bin_length, frs_list)
        ret_list = get_mean_std_time_gaps(bin_length,max_pkt_size,times_dic)
        ret_lists.append( ret_list)


    return ret_lists

def get_featuers_for_each_size_bin(param_dict,time_gaps_lists,param_sz_lists):
    bin_length = param_dict['bin_length']
    max_pkt_size = param_dict['max_pkt_size']
    block_size = param_dict['block_size']
    time_window = param_dict['time_window']
    segregated_pkt_list = param_dict['segregated_pkt_list']
    time_1stframe = param_dict['time_1stframe']

    #lists - mgmt, ctrl, data
    #segregated_pkt_list = global_feats_list[4]
    #mgmt frames lists
    mgmt_all_list = segregated_pkt_list[0]
    mgmt_sent_list = segregated_pkt_list[1]
    mgmt_recv_list = segregated_pkt_list[2]
    #ctrl frames lists
    ctrl_all_list = segregated_pkt_list[3]
    ctrl_sent_list = segregated_pkt_list[4]
    ctrl_recv_list = segregated_pkt_list[5]
    #data frames lists
    data_all_list = segregated_pkt_list[6]
    data_sent_list = segregated_pkt_list[7]
    data_recv_list = segregated_pkt_list[8]

    #print('len(bin_ld_list)= ',len(bin_ld_list), ' len(bin_f_ld_list) = ',len(bin_f_ld_list),'  len(mean_gaps_list)= ',len(mean_gaps_dic), ' len(std_gaps_list)= ',len(std_gaps_dic))
    bins_count = (max_pkt_size / bin_length) + 1

    #final feature list for this block --
    features_all_data_list = list()
    features_sent_data_list = list()
    features_recv_data_list = list()
    features_all_data_list.append(block_size)
    features_all_data_list.append(time_1stframe)
    features_all_data_list.append(time_window)

    features_sent_data_list.append(block_size)
    features_sent_data_list.append(time_1stframe)
    features_sent_data_list.append(time_window)

    features_recv_data_list.append(block_size)
    features_recv_data_list.append(time_1stframe)
    features_recv_data_list.append(time_window)

    #features on management frames ---------
    #c == count, fr == fraction, mx = mgmt sent or receive, ms == mgmt sent, mr  == mgmt receive
    #us == count of unique sizes of frames, mn == mean , sd  == std
    #xs == sizes of all frames
    #features_name += ['c_c_mx','f_fr_mx_x','c_c_mx_us','f_mn_mx_xs','f_sd_mx_xs']
    #features_name += ['c_c_ms','f_fr_ms_mx','c_c_ms_us','f_mn_ms_xs','f_sd_ms_xs']
    #features_name += ['c_c_mr','f_fr_mr_mx','c_c_mr_us','f_mn_mr_xs','f_sd_mr_xs']
    mgmt_lists = [mgmt_all_list,mgmt_sent_list,mgmt_recv_list]
    for ii in range(3):
        mlist = mgmt_lists[ii]

        mgmt_sz_list = get_frame_sizes(mlist)
        c_m = len(mgmt_sz_list)
        #print('ii = ',ii, ' ctrl : count = ', c_m)
        fq_m = (1.0 * c_m ) / block_size
        u_list = np.unique(mgmt_sz_list)
        mn_m = 0.0
        if c_m > 0:
            mn_m = np.mean(mgmt_sz_list)
        sd_m = 0.0
        if c_m > 0:
            sd_m =np.std(mgmt_sz_list)
        ft_list = list()
        if ii == 0:
            ft_list = features_all_data_list
        if ii == 1:
            ft_list = features_sent_data_list
        if ii == 2:
            ft_list = features_recv_data_list
        ft_list.append(c_m)
        ft_list.append(fq_m)
        ft_list.append(len(u_list))
        ft_list.append(mn_m)
        ft_list.append(sd_m)

    #print('mgmt: len(features_all_data_list) = ',len(features_all_data_list))
    #features on control frames -------------
    #features_name += ['c_c_cx','f_fr_cx_x','c_c_cx_us','f_mn_cx_xs','f_sd_cx_xs']
    #features_name += ['c_c_cs','f_fr_cs_cx','c_c_cs_us','f_mn_cs_xs','f_sd_cs_xs']
    #features_name += ['c_c_cr','f_fr_cr_cx','c_c_cr_us','f_mn_cr_xs','f_sd_cr_xs']
    ctrl_lists = [ctrl_all_list,ctrl_sent_list,ctrl_recv_list]
    for ii in range(3):
        clist = ctrl_lists[ii]
        ctrl_sz_list = get_frame_sizes(clist)
        c_c = len(ctrl_sz_list)
        fq_c = (1.0 * c_c ) / block_size
        u_list = np.unique(ctrl_sz_list)
        mn_c = 0.0
        if c_c > 0:
            mn_c = np.mean(ctrl_sz_list)
        sd_c = 0.0
        if c_c > 0:
            sd_c = np.std(ctrl_sz_list)
        ft_list = list()
        if ii == 0:
            ft_list = features_all_data_list
        if ii == 1:
            ft_list = features_sent_data_list
        if ii == 2:
            ft_list = features_recv_data_list

        ft_list.append(c_c)
        ft_list.append(fq_c)
        ft_list.append(len(u_list))
        ft_list.append(mn_c)
        ft_list.append(sd_c)
    #print('ctrl: len(features_all_data_list) = ',len(features_all_data_list))
    #features on data frames --------------
    #features_name += ['c_c_dx','f_fr_dx_x','c_c_dx_us','f_mn_dx_xs','f_sd_dx_xs']
    #features_name += ['c_c_ds','f_fr_ds_dx','c_c_ds_us','f_mn_ds_xs','f_sd_ds_xs']
    #features_name += ['c_c_dr','f_fr_dr_dx','c_c_dr_us','f_mn_dr_xs','f_sd_dr_xs']
    data_lists = [data_all_list,data_sent_list,data_recv_list]
    for ii in range(3):
        dlist = data_lists[ii]
        data_sz_list = get_frame_sizes(dlist)
        c_d = len(data_sz_list)
        fq_d = (1.0 * c_d ) / block_size
        u_list = np.unique(data_sz_list)
        mn_d = 0.0
        if c_d > 0:
            mn_d = np.mean(data_sz_list)
        sd_d = 0.0
        if c_d > 0:
            sd_d = np.std(data_sz_list)
        ft_list = list()
        if ii == 0:
            ft_list = features_all_data_list
        if ii == 1:
            ft_list = features_sent_data_list
        if ii == 2:
            ft_list = features_recv_data_list

        ft_list.append(c_d)
        ft_list.append(fq_d)
        ft_list.append(len(u_list))
        ft_list.append(mn_d)
        ft_list.append(sd_d)

    #features on data frame sizes based on bins -- all traffic
    #c_c_dx_b_ == integer count of all data frames in bin id b_
    #f_fr_dx_tb_b_ == float fraction on all data frames in bin id b_ to the total number data frames in all bins
    #f_mn_xs_dx_b_ == float mean of the frame sizes of all data frames in bin id b_
    #f_sd_xs_dx_b_ == float std of the frame sizes of all data frames in bin id b_
    #f_mn_tg_dx_b_ == float mean of time gaps of all the data frames in bin id b_
    #f_sd_tg_dx_b_ == float std of time gaps of all the data frames in bin id b_
    #*_ds_*  == sent data frames
    #*_dr_* == recv data frames
    #feat_str = ['c_c_dx_b_','f_fr_dx_tb_b_','f_mn_xs_dx_b_','f_sd_xs_dx_b_','f_mn_tg_dx_b_','f_sd_tg_dx_b_']
    #feat_str = ['c_c_ds_b_','f_fr_ds_tb_b_','f_mn_xs_ds_b_','f_sd_xs_ds_b_','f_mn_tg_ds_b_','f_sd_tg_ds_b_']
    #feat_str = ['c_c_dr_b_','f_fr_dr_tb_b_','f_mn_xs_dr_b_','f_sd_xs_dr_b_','f_mn_tg_dr_b_','f_sd_tg_dr_b_']
    #features on traffic irrespective of travel directions ..
    #for ft_list in param_sz_lists:
    #print('data: len(features_all_data_list) = ',len(features_all_data_list))
    for index in range(3):# for all, sent, recv
        data_bins_list = param_sz_lists[index]
        tg_lists = time_gaps_lists[index]
        #print(' len(data_bins_list) = ', len(data_bins_list), ' len(tg_lists) = ',len(tg_lists))

        bin_ld_list = data_bins_list[0]
        bin_f_ld_list = data_bins_list[1]
        mn_ld_list = data_bins_list[2]
        sd_ld_list = data_bins_list[3]
        #features on time gaps per bins
        mean_gaps_dic = tg_lists[0]
        std_gaps_dic = tg_lists[1]
        ft_list = list()
        if index == 0:
            ft_list = features_all_data_list
        if index == 1:
            ft_list = features_sent_data_list
        if index == 2:
            ft_list = features_recv_data_list

        for ii in np.arange(0,bins_count):
            i = int(ii)
            ft_list.append(bin_ld_list[i])
            ft_list.append(bin_f_ld_list[i])
            ft_list.append(mn_ld_list[i])
            ft_list.append(sd_ld_list[i])
            ft_list.append(mean_gaps_dic[i])
            ft_list.append(std_gaps_dic[i])

    #features on the data frame sizes -- based on bins -- sent and recv traffic
    #print('len(features_all_data_list) = ',len(features_all_data_list))
    #print(features_list)
    return [features_all_data_list,features_sent_data_list,features_recv_data_list]
########################
def report_feature_description(read_me):
    feat_name = list()
    feat_desc = list()
    feat_name.append('t_mac')
    feat_desc.append('(text) mac address of the IoT device')
    feat_name.append('t_label')
    feat_desc.append('(text) indicates a high level brief description of the activity performed by device, e.g., streaming or idle')
    feat_name.append('c_blk_sz')
    feat_desc.append(' (int) frames in a pcap file is grouped into blocks of equal size, called block size, and each block of frames are processed to extract feaures')
    feat_name.append('f_time_window')
    feat_desc.append(' (real) time difference of last frame and first frame in a block')

    #features_name += ['c_c_mx','f_fr_mx_x','c_c_mx_us','f_mn_mx_xs','f_sd_mx_xs']
    feat_name.append('c_c_mx')
    feat_desc.append('(int) count of number of all management frames (both sent and received) in a block')
    feat_name.append('f_fr_mx_x')
    feat_desc.append('(real) ratio between no. of all management frames and no. of all frames')
    feat_name.append('c_c_mx_us')
    feat_desc.append('(int) no. of unique sizes of all management frames in a block')
    feat_name.append('f_mn_mx_xs')
    feat_desc.append('(real) mean of the sizes of all management frames -- sizes of all frames, not only unique sized frames')
    feat_name.append('f_sd_mx_xs')
    feat_desc.append('(real) std of the sizes of all management frames -- sizes of all frames, not only unique sized frames')
    #features_name += ['c_c_ms','f_fr_ms_mx','c_c_ms_us','f_mn_ms_xs','f_sd_ms_xs']
    feat_name.append('c_c_ms')
    feat_desc.append('(int) count of number of only sent management frames from the given MAC address in a block')
    feat_name.append('f_fr_ms_mx')
    feat_desc.append('(real) ratio between no. of sent management frames and block size')
    feat_name.append('c_c_ms_us')
    feat_desc.append('(int) no. of unique sizes of sent management frames in a block')
    feat_name.append('f_mn_ms_xs')
    feat_desc.append('(real) mean of the sizes of sent management frames -- sizes of sent frames, not only unique sized frames')
    feat_name.append('f_sd_ms_xs')
    feat_desc.append('(real) std of the sizes of sent management frames -- sizes of sent frames, not only unique sized frames')

    #features_name += ['c_c_mr','f_fr_mr_mx','c_c_mr_us','f_mn_mr_xs','f_sd_mr_xs']
    feat_name.append('c_c_mr')
    feat_desc.append('(int) count of number of only received management frames by the given MAC address in a block')
    feat_name.append('f_fr_mr_mx')
    feat_desc.append('(real) ratio between no. of recv. management frames and block size')
    feat_name.append('c_c_mr_us')
    feat_desc.append('(int) no. of unique sizes of recv. management frames in a block')
    feat_name.append('f_mn_mr_xs')
    feat_desc.append('(real) mean of the sizes of recv. management frames -- sizes of recv. frames, not only unique sized frames')
    feat_name.append('f_sd_mr_xs')
    feat_desc.append('(real) std of the sizes of recv. management frames -- sizes of recv. frames, not only unique sized frames')

    #features_name += ['c_c_cx','f_fr_cx_x','c_c_cx_us','f_mn_cx_xs','f_sd_cx_xs']
    feat_name.append('c_c_cx')
    feat_desc.append('(int) count of number of all control frames (both sent and received) in a block')
    feat_name.append('f_fr_cx_x')
    feat_desc.append('(real) ratio between no. of all control frames and no. of all frames')
    feat_name.append('c_c_cx_us')
    feat_desc.append('(int) no. of unique sizes of all control frames in a block')
    feat_name.append('f_mn_cx_xs')
    feat_desc.append('(real) mean of the sizes of all control frames -- sizes of all frames, not only unique sized frames')
    feat_name.append('f_sd_cx_xs')
    feat_desc.append('(real) std of the sizes of all control frames -- sizes of all frames, not only unique sized frames')
    #features_name += ['c_c_cs','f_fr_cs_cx','c_c_cs_us','f_mn_cs_xs','f_sd_cs_xs']
    feat_name.append('c_c_cs')
    feat_desc.append('(int) count of number of only sent control frames from the given MAC address in a block')
    feat_name.append('f_fr_cs_cx')
    feat_desc.append('(real) ratio between no. of sent control frames and block size')
    feat_name.append('c_c_cs_us')
    feat_desc.append('(int) no. of unique sizes of sent control frames in a block')
    feat_name.append('f_mn_cs_xs')
    feat_desc.append('(real) mean of the sizes of sent control frames -- sizes of sent frames, not only unique sized frames')
    feat_name.append('f_sd_cs_xs')
    feat_desc.append('(real) std of the sizes of sent control frames -- sizes of sent frames, not only unique sized frames')

    #features_name += ['c_c_cr','f_fr_cr_cx','c_c_cr_us','f_mn_cr_xs','f_sd_cr_xs']
    feat_name.append('c_c_cr')
    feat_desc.append('(int) count of number of only received control frames by the given MAC address in a block')
    feat_name.append('f_fr_cr_cx')
    feat_desc.append('(real) ratio between no. of recv. control frames and block size')
    feat_name.append('c_c_cr_us')
    feat_desc.append('(int) no. of unique sizes of recv. control frames in a block')
    feat_name.append('f_mn_cr_xs')
    feat_desc.append('(real) mean of the sizes of recv. control frames -- sizes of recv. frames, not only unique sized frames')
    feat_name.append('f_sd_cr_xs')
    feat_desc.append('(real) std of the sizes of recv. control frames -- sizes of recv. frames, not only unique sized frames')

    #features_name += ['c_c_dx','f_fr_dx_x','c_c_dx_us','f_mn_dx_xs','f_sd_dx_xs']
    feat_name.append('c_c_dx')
    feat_desc.append('(int) count of number of all data frames (both sent and received) in a block')
    feat_name.append('f_fr_dx_x')
    feat_desc.append('(real) ratio between no. of all data frames and no. of all frames')
    feat_name.append('c_c_dx_us')
    feat_desc.append('(int) no. of unique sizes of all data frames in a block')
    feat_name.append('f_mn_dx_xs')
    feat_desc.append('(real) mean of the sizes of all data frames -- sizes of all frames, not only unique sized frames')
    feat_name.append('f_sd_dx_xs')
    feat_desc.append('(real) std of the sizes of all data frames -- sizes of all frames, not only unique sized frames')
    #features_name += ['c_c_ds','f_fr_ds_dx','c_c_ds_us','f_mn_ds_xs','f_sd_ds_xs']
    feat_name.append('c_c_ds')
    feat_desc.append('(int) count of number of only sent data frames from the given MAC address in a block')
    feat_name.append('f_fr_ds_dx')
    feat_desc.append('(real) ratio between no. of sent data frames and block size')
    feat_name.append('c_c_ds_us')
    feat_desc.append('(int) no. of unique sizes of sent data frames in a block')
    feat_name.append('f_mn_ds_xs')
    feat_desc.append('(real) mean of the sizes of sent data frames -- sizes of sent frames, not only unique sized frames')
    feat_name.append('f_sd_ds_xs')
    feat_desc.append('(real) std of the sizes of sent data frames -- sizes of sent frames, not only unique sized frames')

    #features_name += ['c_c_dr','f_fr_dr_dx','c_c_dr_us','f_mn_dr_xs','f_sd_dr_xs']
    feat_name.append('c_c_dr')
    feat_desc.append('(int) count of number of only received data frames by the given MAC address in a block')
    feat_name.append('f_fr_dr_mx')
    feat_desc.append('(real) ratio between no. of recv. data frames and block size')
    feat_name.append('c_c_dr_us')
    feat_desc.append('(int) no. of unique sizes of recv. data frames in a block')
    feat_name.append('f_mn_dr_xs')
    feat_desc.append('(real) mean of the sizes of recv. data frames -- sizes of recv. frames, not only unique sized frames')
    feat_name.append('f_sd_dr_xs')
    feat_desc.append('(real) std of the sizes of recv. data frames -- sizes of recv. frames, not only unique sized frames')

    #feat_str = ['c_c_dx_b_','f_fr_dx_tb_b_','f_mn_xs_dx_b_','f_sd_xs_dx_b_','f_mn_tg_dx_b_','f_sd_tg_dx_b_']
    feat_name.append('c_c_dx_b_')
    feat_desc.append('(int) count of number of all data frames for the given MAC address in bin index b_i (bin index = frame size / bin length)')
    feat_name.append('f_fr_dx_tb_b_')
    feat_desc.append('(real) ratio of number of all data frames in bin index b_i and number of all frames in the block)')
    feat_name.append('f_mn_xs_dx_b_')
    feat_desc.append('(real) mean of the sizes of all data frames in bin index b_i')
    feat_name.append('f_sd_xs_dx_b_')
    feat_desc.append('(real) std of the sizes of all data frames in bin index b_i')
    feat_name.append('f_mn_tg_dx_b_')
    feat_desc.append('(real) mean of time gaps between all data frames in bin index b_i')
    feat_name.append('f_sd_tg_dx_b_')
    feat_desc.append('(real) std of time gaps between all data frames in bin index b_i')

    #feat_str = ['c_c_ds_b_','f_fr_ds_tb_b_','f_mn_xs_ds_b_','f_sd_xs_ds_b_','f_mn_tg_ds_b_','f_sd_tg_ds_b_']
    feat_name.append('c_c_ds_b_')
    feat_desc.append('(int) count of number of send data frames for the given MAC address in bin index b_i (bin index = frame size / bin length)')
    feat_name.append('f_fr_ds_tb_b_')
    feat_desc.append('(real) ratio of number of send data frames in bin index b_i and number of all frames in the block)')
    feat_name.append('f_mn_xs_ds_b_')
    feat_desc.append('(real) mean of the sizes of send data frames in bin index b_i')
    feat_name.append('f_sd_xs_ds_b_')
    feat_desc.append('(real) std of the sizes of send data frames in bin index b_i')
    feat_name.append('f_mn_tg_ds_b_')
    feat_desc.append('(real) mean of time gaps between send data frames in bin index b_i')
    feat_name.append('f_sd_tg_ds_b_')
    feat_desc.append('(real) std of time gaps between send data frames in bin index b_i')

    #feat_str = ['c_c_dr_b_','f_fr_dr_tb_b_','f_mn_xs_dr_b_','f_sd_xs_dr_b_','f_mn_tg_dr_b_','f_sd_tg_dr_b_']
    feat_name.append('c_c_dr_b_')
    feat_desc.append('(int) count of number of recv. data frames for the given MAC address in bin index b_i (bin index = frame size / bin length)')
    feat_name.append('f_fr_dr_tb_b_')
    feat_desc.append('(real) ratio of number of recv. data frames in bin index b_i and number of all frames in the block)')
    feat_name.append('f_mn_xs_dr_b_')
    feat_desc.append('(real) mean of the sizes of recv. data frames in bin index b_i')
    feat_name.append('f_sd_xs_dr_b_')
    feat_desc.append('(real) std of the sizes of recv. data frames in bin index b_i')
    feat_name.append('f_mn_tg_dr_b_')
    feat_desc.append('(real) mean of time gaps between recv. data frames in bin index b_i')
    feat_name.append('f_sd_tg_dr_b_')
    feat_desc.append('(real) std of time gaps between recv. data frames in bin index b_i')

    tot_feats = len(feat_name)
    fhandle = open(read_me,'w')
    for i in range(tot_feats):
        line = '%s == %s\n'%(feat_name[i],feat_desc[i])
        fhandle.write(line)
    fhandle.close()
##################
def get_features(mac,pkt_list,bin_length,max_pkt_size,block_size):
    ret_ft_list = list()

    controlc=0
    managec=0
    normalc=0
    #read all packets from file
    pkt_count = len(pkt_list)
    #print('pkt_count = ',pkt_count,' block_size = ', block_size)
    if pkt_count >= block_size:
        rounds = int(pkt_count/block_size)
        for i in np.arange(rounds):
            #if i % 10 == 0:
            #    print('round '+str(i) + '/' + str(rounds))
            min_index = int(i)*block_size
            #max_index = (i+1)*block_size
            max_index = min_index + block_size
            #print('min_index = ', min_index, ' max_index = ', max_index, ' pkt_count = ', pkt_count,' round = ', rounds, ' i = ', i)
            pkts = pkt_list[min_index:max_index]
            pkt1 = pkts[0]
            pkt2 = pkts[block_size - 1]
            time_window = pkt2.time - pkt1.time
            time_1stframe = pkt1.time
            #print('block stat: mac: ',mac, ' pkt_count = ', len(pkts), ' time_1stpkt = ',pkt1.time, ' time_lastpkt = ', pkt2.time, ' bn= ', bin_length, ' bs = ', block_size)
            segregated_pkt_list = get_type_based_size_lists(mac,pkts)
            #only mgmt frames
            mgmt_count = len(segregated_pkt_list[0])
            #only ctrl frames
            ctrl_count = len(segregated_pkt_list[3])
            #only data frames
            data_count = len(segregated_pkt_list[6])
            total_pkt_count = mgmt_count + ctrl_count + data_count
            if block_size != total_pkt_count:
                print('i = ', i, ' blk_size = ',block_size, ' total_pkt_count = ', total_pkt_count)
            #segregate the packets into sent and received packets

            param_list = list()
            param_list.append(bin_length)
            param_list.append(max_pkt_size)
            param_list.append(block_size)
            param_list.append(time_window)
            param_list.append(segregated_pkt_list) #mgmt packt size list
            param_dict = dict()
            param_dict['bin_length'] = bin_length
            param_dict['max_pkt_size'] = max_pkt_size
            param_dict['block_size'] = block_size
            param_dict['time_window'] = time_window
            param_dict['segregated_pkt_list'] = segregated_pkt_list
            param_dict['time_1stframe'] = time_1stframe

            #print('mgmt_count = ', mgmt_count, ' ctrl_count = ', ctrl_count, ' data_count = ', data_count)
            ret_sz_feats_lists = get_features_from_size_dist(bin_length,max_pkt_size,segregated_pkt_list)

            time_gaps_lists = get_time_gaps_each_bin(bin_length,max_pkt_size,segregated_pkt_list)

            #get formated list of features
            features_list_this_block = get_featuers_for_each_size_bin(param_dict,time_gaps_lists,ret_sz_feats_lists)
            #print('block id = ',i,'count feautes = ', len(features_list_this_block))
            ret_ft_list.append(features_list_this_block)

    else:
        print('no. of packets (= )',str(pkt_count),') is less than block size ( = ',str(block_size))
    return ret_ft_list
def check(part_fs_list):
    all_list = part_fs_list[0]
    sent_list = part_fs_list[1]
    recv_list = part_fs_list[2]
    is_all_sent = True
    is_all_recv = True
    feats_count = len(all_list)
    for i in range(feats_count):
        if all_list[i] != sent_list[i]:
            is_all_sent = False
        if all_list[i] != recv_list[i]:
            is_all_recv = False
    if (is_all_sent == True) and (is_all_recv == True):
        print(' -------------all same ------------')
        return True
    else:
        return False

def get_formated_feats_list(mac,label,features_list):
    formated_feats_list = list()
    for ft_sets in features_list:
        part_fs_list = list()

        for ft_set in ft_sets:
            feats_list = list()
            feats_list.append(mac)
            feats_list.append(label)
            for ft in ft_set:
                feats_list.append(ft)
            part_fs_list.append(feats_list)
            #print('feats count = ', len(feats_list))
        if check(part_fs_list):
            break
        formated_feats_list.append(part_fs_list)

    return formated_feats_list
def get_label(fname):
    #print('fname = ', fname)
    toks = fname.split('/')

    num_toks = len(toks)
    flabel = toks[num_toks-1]
    toks = flabel.split('_')
    dev_name = toks[2]
    label = toks[2]+'_'+toks[3]
    if 'attack' in flabel:
        label = toks[2]+'_'+toks[3] + '_' +toks[4] + '_' + toks[5]
    #print('fname = ', fname, ' label = ', label)
    return dev_name,label

def get_mac(label):
    mac = 'unknow'
    mac_label_dic = get_mac_label_dic()
    for lb in mac_label_dic:
        if lb in label:
            mac = mac_label_dic[lb]
            break
    #print(' label = ',label,' mac = ',mac)
    return mac

def store_feature_in_db(db_name,table_name,formated_features_list):
    conek = lite.connect(db_name)
    csor = conek.cursor()
    sig_count = len(formated_features_list)
    for ft_lists in formated_features_list:
        ########### insert into all data  frames ##################
        ft_list = ft_lists[0]
        stmt = 'insert into '+table_name +'_all_dframes values('
        fts_count = len(ft_list)

        for ft in ft_list[:-1]:
            stmt += '?, '
        stmt +=  ' ?)'
        #print('len(ft_list) = ', len(ft_list))
        csor.execute(stmt,ft_list)
        ########### insert into sent data frames ##################
        ft_list = ft_lists[1]
        stmt = 'insert into '+table_name +'_sent_dframes values('
        fts_count = len(ft_list)

        for ft in ft_list[:-1]:
            stmt += '?, '
        stmt +=  ' ?)'
        #print('len(ft_list) = ', len(ft_list))
        csor.execute(stmt,ft_list)
        ########### insert into recv data frames ##################
        ft_list = ft_lists[2]
        stmt = 'insert into '+table_name +'_recv_dframes values('
        fts_count = len(ft_list)

        for ft in ft_list[:-1]:
            stmt += '?, '
        stmt +=  ' ?)'
        #print('len(ft_list) = ', len(ft_list))
        csor.execute(stmt,ft_list)
    conek.commit()
    conek.close()
    return sig_count
def extract_packet_features(db_name,tab_name_packet_features,fname):
    label = get_label(fname)
    my_reader = PcapReader(fname)
    print('extracting packet features: label = ',label)
    pkts = my_reader.read_all()
    store_packet_features(pkts,db_name,tab_name_packet_features,label)
    my_reader.close()

def extract_traffic_features(bin_length,max_pkt_size,block_size,fname,db_name,tab_name_traffic_features):
    dev_name,label = get_label(fname)
    mac = get_mac(dev_name)
    my_reader = PcapReader(fname)
    pkts = my_reader.read_all()
    print('extracting traffic features: bin size = ', bin_length, ' and block size = ',block_size, ' mac = ', mac, ' label = ',label)
    features_list = get_features(mac,pkts,bin_length,max_pkt_size,block_size)
    #make featureses compatible to insert to database :  add mac and label to the signatures extracted

    formated_feats_list = get_formated_feats_list(mac,label,features_list)
    sig_count = store_feature_in_db(db_name,tab_name_traffic_features,formated_feats_list)
    my_reader.close()
    return sig_count

def extract_n_store_features(fname_list,is_pkt_feats,is_trf_feats,db_name,table_pkt_feats,bn_len,max_pkt_size,blk_size,table_trf_feats):
    total_f_count = len(fname_list)
    fc = 0
    sig_count_list = list()
    for fname in fname_list:
        print(' Processing file '+str(fc+1)+'/'+str(total_f_count), ' fname = ', fname)
        fc += 1
        #extract packet based basic features
        if is_pkt_feats:
            extract_packet_features(db_name,table_pkt_feats,fname)

        #extract features from the packets in a file given the bin_length, max_pkt_size, and block_size
        if is_trf_feats:
            sig_count = extract_traffic_features(bn_len,max_pkt_size,blk_size,fname,db_name,table_trf_feats)
            sig_count_list.append(sig_count)
    return sig_count_list

def get_mac_label_dic():
    mac_label_dic = {}
    mac_label_dic['smallEcho'] = '40:b4:cd:e4:e6:4b'
    mac_label_dic['echo'] = '44:65:0d:ad:8e:2b'
    mac_label_dic['nestCam'] = '18:b4:30:53:18:42'
    mac_label_dic['nestcam'] = '18:b4:30:53:18:42'
    mac_label_dic['netatmo'] = '70:ee:50:16:ed:2b'
    mac_label_dic['phone'] = 'c0:ee:fb:d4:80:ac'
    mac_label_dic['printer'] = 'ec:b1:d7:d3:02:46'
    mac_label_dic['lenovo'] = 'a0:32:99:04:50:c4'
    mac_label_dic['withings'] = '00:24:e4:2b:95:11'
    mac_label_dic['tplinkcam'] = '60:e3:27:54:90:eb'
    mac_label_dic['tplinkcam'] = '60:e3:27:54:90:eb'
    mac_label_dic['tplinkbulb185'] = '50:c7:bf:24:e3:5f'
    mac_label_dic['tplinkbulb137'] = '50:c7:bf:40:7d:2c'
    mac_label_dic['philipshuebulb1'] = '00:17:88:01:10:3c:1b:ee-0b'
    mac_label_dic['philipshuebulb2'] = '00:17:88:01:10:3c:1b:c3-0b'
    mac_label_dic['philipshuebulb3'] = '00:17:88:01:10:3c:1b:7d-0b'
    mac_label_dic['dlinkcam62879313'] = 'b2:c5:54:2e:00:0c'

    return mac_label_dic

def get_file_name(dir_name):
    trace_processed_dir = '../trace_data_camera/trace_processed/'
    trace_processed_dir = '../trace_data_camera/dlink_yufei/'
    trace_processed_dir = '../trace_data_yufei/Camera/'
    trace_processed_dir = '../trace_data_yufei/Echo/'
    trace_processed_dir = '../trace_data_yufei/Phone/'
    trace_processed_dir = '../trace_data_yufei/Printer/'
    trace_processed_dir = '../trace_data_yufei/Tablet/'
    trace_processed_dir = '../trace_data_attack_yufei/Camera/'
    trace_processed_dir = dir_name
    fname_list = list()
    for file in os.listdir(trace_processed_dir):
        if file.endswith(".pcap"):
            fn = os.path.join(trace_processed_dir, file)
            print(fn)
            fname_list.append(fn)
    return fname_list

def get_all_file_names():
    fname_list = list()
    dir_list = ['../trace_data_yufei/Camera/']
    #dir_list += ['../trace_data_yufei/Echo/','../trace_data_yufei/Phone/']
    #dir_list += ['../trace_data_yufei/Printer/','../trace_data_yufei/Tablet/']
    for dir_name in dir_list:
        for fl in os.listdir(dir_name):
            if fl.endswith(".pcap"):
                fn = os.path.join(dir_name, fl)
                print(fn)
                fname_list.append(fn)

    return fname_list
def get_all_attack_files_names():
    fname_list = list()
    dir_list = ['../trace_data_attack_yufei/Camera/']
    #dir_list += ['../trace_data_attack_yufei/Echo/','../trace_data_attack_yufei/Phone/']
    #dir_list += ['../trace_data_attack_yufei/Printer/','../trace_data_attack_yufei/Tablet/']
    for dir_name in dir_list:
        for fl in os.listdir(dir_name):
            if fl.endswith(".pcap"):
                fn = os.path.join(dir_name,fl)
                print(fn)
                fname_list.append(fn)
    return fname_list

def compute_collection_time(fname_list):
    total_tw = 0
    tot_pkts = 0
    tot_files = len(fname_list)
    fl = 0
    for fn in fname_list:
        print(' reading file no : {0}/{1}, total_pkts: {2} , total_tw: {3}'.format((fl+1),tot_files,tot_pkts,total_tw))
        my_reader = PcapReader(fn)
        pkts = my_reader.read_all()
        t1 = pkts[0].time
        pkts_count = len(pkts)
        t2 = pkts[pkts_count-1].time
        tw = t2 - t1
        total_tw += tw
        tot_pkts += pkts_count
        my_reader.close()
        fl += 1
    print('total_tw = ',total_tw, '  pkts_count = ',tot_pkts)
def get_db_file_name(bin_length,block_size,is_create):
    base_attack_db = '../feature_dbs/base_attack_traffic.db'
    db_name = '../Aug_demo_trace/feats_dbs/test_or_demo/temp_db_sigs_bnl'+str(bin_length) +'_bks'+str(block_size)+'.db'
    if is_create:
        print('creating db file: ', db_name)
        su.copy2(base_attack_db,db_name)
    else:
        print('using db file: ', db_name)
    return db_name
def extract_features_from(fname_list):
    max_pkt_size = 1600
    is_pkt_feats = False
    is_trf_feats = True
    table_trf_feats = 'attack_traffic_features'
    table_pkt_feats = 'attack_packet_features'
    #list_run_time = list()
    #extract features
    #for blk_size in [50,100,200,300,400,500]:
    for blk_size in [300]:
        for bn_len in [800]:
            #s_st_time = time.time()
            is_db_create = False
            db_name = get_db_file_name(bn_len,blk_size,is_db_create)
            create_database(bn_len,max_pkt_size,db_name,table_trf_feats,table_pkt_feats)
            sig_count_list = extract_n_store_features(fname_list,is_pkt_feats,is_trf_feats,db_name,table_pkt_feats,bn_len,max_pkt_size,blk_size,table_trf_feats)
            #e_st_time = time.time()
            #delta_time = e_st_time - s_st_time
            #sample = [blk_size, bn_len, sig_count_list, delta_time]
            #list_run_time.append(sample)
    etime = time.time()
    rtime = etime - stime
    #print("run for : " + str(rtime) + "s")
    #for rt in list_run_time:
    #    print rt
################################################################
################################################################
#live capture for demo
pkt_list = list()
valid_pkt_count = 0
target_mac = ''
block_size = 300
def is_target_pkt(pkt):
    a1 = getUnicodeToAscii(str(pkt.addr1))
    a1str = a1.decode('utf-8')
    a2 = getUnicodeToAscii(str(pkt.addr2))
    a2str = a2.decode('utf-8')
    a3 = getUnicodeToAscii(str(pkt.addr3))
    a3str = a3.decode('utf-8')
    a4 = getUnicodeToAscii(str(pkt.addr4))
    a4str = a4.decode('utf-8')
    is_valid = False
    if target_mac in [a1str,a2str,a3str,a4str]:
        is_valid = True
    return is_valid
def store_pandas_dataframe(pd_fname,feats_sets,formated_feats_list):
    return ''
def store_feats_in_csv(csv_fname,feats_sets,formated_feats_list):
    is_exists = os.path.isfile(csv_fname)

    ft_set = feats_sets[0]
    ft_set += feats_sets[1][5:]
    ft_set += feats_sets[2][5:]
    #print('ft_set')
    if not is_exists:
        writer = csv.writer(open(csv_fname, 'a'))
        writer.writerow(ft_set)
    else:
        writer = csv.writer(open(csv_fname, 'a'))
    #features_names_sr = ['t_mac','t_label','c_blk_sz','f_time_fstframe','f_time_window']
    #features_names_sr += ['c_c_mx','f_fr_mx_x','c_c_mx_us','f_mn_mx_xs','f_sd_mx_xs']

    #features_names_s = ['t_mac','t_label','c_blk_sz','f_time_fstframe','f_time_window']
    #features_names_s += ['c_c_ms','f_fr_ms_mx','c_c_ms_us','f_mn_ms_xs','f_sd_ms_xs']

    #features_names_r = ['t_mac','t_label','c_blk_sz','f_time_fstframe','f_time_window']
    #features_names_r += ['c_c_mr','f_fr_mr_mx','c_c_mr_us','f_mn_mr_xs','f_sd_mr_xs']

    for ft_lists in formated_feats_list:
        row_items = list()
        ########### insert into all data  frames ##################
        ft_list = ft_lists[0]
        row_items = ft_list

        ########### insert into sent data frames ##################
        ft_list = ft_lists[1]
        fts_count = len(ft_list)
        row_items += ft_list[5:] #discard initial 4 itmes as they are present in row_items already

        ########### insert into recv data frames ##################
        ft_list = ft_lists[2]
        row_items += ft_list[5:]
        writer.writerow(row_items)

    return ''

def get_db_file_name_live_capture(bin_length,block_size,max_pkt_size,table_pkt_feats,table_trf_feats):
    base_attack_db = './demo/base_attack_traffic.db'
    db_name = './demo/live_db_sigs_bnl'+str(bin_length) +'_bks'+str(block_size)+'.db'
    is_exists = os.path.isfile(db_name)

    feats_names_sets = get_feats_names_set(max_pkt_size,bin_length)
    if not is_exists:
        print('creating db file: ', db_name)
        su.copy2(base_attack_db,db_name)
        create_database(bin_length,max_pkt_size,db_name,table_trf_feats,table_pkt_feats)
    #else:
    #    print('using db file: ', db_name)
    return db_name,feats_names_sets
def extract_n_store_sig_from_pkt_list(pkt_list):
    global target_mac,block_size
    bin_length = 800
    max_pkt_size = 1600
    label = 'unknown'
    table_pkt_feats = 'attack_packet_features'#place holder
    table_trf_feats = 'attack_traffic_features'
    pd_fname = '../Aug_demo_trace/feats_dbs/test_or_demo/pandas_data_frame.csv'
    csv_fname = './demo/live_anomaly_sigs.csv'
    ########################
    db_name, feats_names_sets = get_db_file_name_live_capture(bin_length,block_size,max_pkt_size,table_pkt_feats,table_trf_feats)
    #########################

    #print('creating signatures live: bin size = ', bin_length, ' and block size = ',block_size, ' target mac = ', target_mac, ' label = ',label)
    features_list = get_features(target_mac,pkt_list,bin_length,max_pkt_size,block_size)
    #make featureses compatible to insert to database :  add mac and label to the signatures extracted

    formated_feats_list = get_formated_feats_list(target_mac,label,features_list)

    sig_count = store_feature_in_db(db_name,table_trf_feats,formated_feats_list)
    #pd_frame = store_pandas_dataframe(pd_fname,feats_sets,formated_feats_list)
    sig_count = store_feats_in_csv(csv_fname,feats_names_sets, formated_feats_list)

def process_frames(pkt):
    global pkt_list,block_size,valid_pkt_count

    if not is_target_pkt(pkt):
        return

    valid_pkt_count += 1
    pkt_list.append(pkt)
    if valid_pkt_count == block_size:
        extract_n_store_sig_from_pkt_list(pkt_list)
        pkt_list = list()
        valid_pkt_count = 0

def live_pkt_capture_n_extract_sigs(tgt_mac='b2:c5:54:2e:00:0c'):
    dir_name = './demo/'
    fname_list = get_file_name(dir_name)

    global target_mac
    target_mac = tgt_mac

    sniff(offline=fname_list[0],prn=process_frames)
    #sniff(iface="mon0", prn=process_frames,count = 0)
#################################################
#################################################
#   to run =>  only change the folder name in w.r.t. current directory
#         in get_file_name() function
################################################
if __name__ == '__main__':
    stime = time.time()
    #get pcap file name and db file name

    #Aug_demo_feats_dbs
    #for demo in aug
    dir_name = '../Aug_demo_trace/test_or_demo/'
    #fname_list = get_file_name(dir_name)# -- main program
    #to report feature description used in ids ---
    #dir_name = '../../Documentation/'
    #read_me = 'ids_features_description.csv'
    #report_feature_description(dir_name+read_me)

    #compute_collection_time(fname_list)
    #extract_features_from(fname_list)---main program

    mac = 'b2:c5:54:2e:00:0c'
    live_pkt_capture_n_extract_sigs(mac)
