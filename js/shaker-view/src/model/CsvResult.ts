export type ResultRecord = {
  timestamp: number;
  name: string;
  host: string;
  status: number;
  pid: string;
  responseTime: number;
  user: string;
  iteration: string;
  message: string;
}

export class CsvResult {
  public records: ResultRecord[]

  constructor () {
    this.records = []
  }

  static Parse (lines: string[][]) {
    const _records: ResultRecord[] = []

    lines.forEach(line => {
      const record: ResultRecord = {
        timestamp: Number.parseInt(line[0]),
        name: line[1],
        host: line[2],
        status: Number.parseInt(line[3]),
        pid: line[4],
        responseTime: Number.parseInt(line[5]),
        user: line[6],
        iteration: line[7],
        message: line[8]
      }

      if (isNaN(record.timestamp)) {
        return
      }

      _records.push(record)
    })

    const _result = new CsvResult()
    _result.records = _records
    return _result
  }
}
