with tmp_r0 as
 (select b.l_date,
         d.l_listing_date,
         b.vc_inter_code,
         d.vc_stock_name,
         b.l_fund_id,
         c.vc_fund_name,
         b.l_current_amount / 10000 as l_t0_amount
    from trade.thisfundstock b,
         trade.tfundinfo c,
         (select a.vc_stock_name, a.vc_inter_code, a.l_listing_date
            from trade.tstockinfo a
           where a.l_listing_date >= '20180101'
             and a.l_listing_date <= '20181231'
             and C_STOCK_TYPE = '1') d
   where b.l_fund_id = c.l_fund_id
     and b.vc_inter_code = d.vc_inter_code
     and b.l_date = (select sf_get_tradedate(a.l_listing_date, -1, 2, '2')
                       from tstockinfo a
                      where a.vc_inter_code = b.vc_inter_code)
   order by b.l_date, b.vc_inter_code, b.l_fund_id asc),
tmp_r1 as
 (select b.l_date,
         b.vc_inter_code,
         d.vc_stock_name,
         b.l_fund_id,
         c.vc_fund_name,
         b.l_current_amount / 10000 as l_t1_amount
    from trade.thisfundstock b,
         trade.tfundinfo c,
         (select a.vc_stock_name, a.vc_inter_code, a.l_listing_date
            from trade.tstockinfo a
           where a.l_listing_date >= '20180101'
             and a.l_listing_date <= '20181231'
             and C_STOCK_TYPE = '1') d
   where b.l_fund_id = c.l_fund_id
     and b.vc_inter_code = d.vc_inter_code
     and b.l_date = d.l_listing_date
     and b.vc_inter_code = d.vc_inter_code
   order by b.l_date, b.vc_inter_code, b.l_fund_id asc),
tmp_r3 as
 (select b.l_date,
         b.vc_inter_code,
         d.vc_stock_name,
         b.l_fund_id,
         c.vc_fund_name,
         b.l_current_amount / 10000 as l_t3_amount
    from trade.thisfundstock b,
         trade.tfundinfo c,
         (select a.vc_stock_name, a.vc_inter_code, a.l_listing_date
            from trade.tstockinfo a
           where a.l_listing_date >= '20180101'
             and a.l_listing_date <= '20181231'
             and C_STOCK_TYPE = '1') d
   where b.l_fund_id = c.l_fund_id
     and b.vc_inter_code = d.vc_inter_code
     and b.l_date = (select sf_get_tradedate(a.l_listing_date, 2, 2, '2')
                       from tstockinfo a
                      where a.vc_inter_code = b.vc_inter_code)
   order by b.l_date, b.vc_inter_code, b.l_fund_id asc),
tmp_r10 as
 (select b.l_date,
         b.vc_inter_code,
         d.vc_stock_name,
         b.l_fund_id,
         c.vc_fund_name,
         b.l_current_amount / 10000 as l_t10_amount
    from trade.thisfundstock b,
         trade.tfundinfo c,
         (select a.vc_stock_name, a.vc_inter_code, a.l_listing_date
            from trade.tstockinfo a
           where a.l_listing_date >= '20180101'
             and a.l_listing_date <= '20181231'
             and C_STOCK_TYPE = '1') d
   where b.l_fund_id = c.l_fund_id
     and b.vc_inter_code = d.vc_inter_code
     and b.l_date = (select sf_get_tradedate(a.l_listing_date, 9, 2, '2')
                       from tstockinfo a
                      where a.vc_inter_code = b.vc_inter_code)
   order by b.l_date, b.vc_inter_code, b.l_fund_id asc),
tmp_end as
 (select min(b.l_date) as l_date, b.vc_inter_code, b.l_fund_id
    from trade.thisfundstock b,
         (select a.vc_stock_name, a.vc_inter_code, a.l_listing_date
            from trade.tstockinfo a
           where a.l_listing_date >= '20180101'
             and a.l_listing_date <= '20181231'
             and C_STOCK_TYPE = '1') d
   where b.vc_inter_code = d.vc_inter_code
     and b.l_current_amount = 0
     and b.l_date >= d.l_listing_date
   group by b.vc_inter_code, b.l_fund_id)

select a.vc_stock_name as 股票名称,
       a.l_listing_date as 上市日,
       a.L_fund_id as 基金编号,
       a.vc_fund_name as 基金名称,
       a.l_t0_amount as 上市前一交易日,
       b.l_t1_amount as 上市首日存量,
       round（(1 - b.l_t1_amount / a.l_t0_amount) * 100,
       2) as 首日卖出比率, c.l_t3_amount as 上市第三日存量, round（(1 - c.l_t3_amount / a.l_t0_amount) * 100, 2) as 上市第三日卖出比率, d.l_t10_amount as 上市第十日存量, round（(1 - d.l_t10_amount / a.l_t0_amount) * 100, 2) as 上市第十日卖出比率, e.l_date as 全部卖出日

  from tmp_r0 a, tmp_r1 b, tmp_r3 c, tmp_r10 d, tmp_end e
 where a.vc_inter_code = b.vc_inter_code(+)
   and a.l_fund_id = b.l_fund_id(+)
   and a.vc_inter_code = c.vc_inter_code(+)
   and a.l_fund_id = c.l_fund_id(+)
   and a.vc_inter_code = d.vc_inter_code(+)
   and a.l_fund_id = d.l_fund_id(+)
   and a.vc_inter_code = e.vc_inter_code(+)
   and a.l_fund_id = e.l_fund_id(+)
   and a.l_t0_amount > 0