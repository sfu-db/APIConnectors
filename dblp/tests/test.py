from dataprep.connector import Connector


def test_sanity():
    dc = Connector("./dblp")
    df = dc.query("publication", q="Database")
    assert len(df) != 0
